#!/usr/bin/env bash

# PostgreSQL Backup & Restore Manager dengan Rofi
# Pastikan rofi dan postgresql-client sudah terinstall

# Konfigurasi
BACKUP_DIR="$HOME/postgres_backups"
LOG_FILE="$BACKUP_DIR/backup.log"

# Buat direktori backup jika belum ada
mkdir -p "$BACKUP_DIR"

# Fungsi untuk logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Fungsi untuk mendapatkan daftar database
get_databases() {
    sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';" 2>/dev/null | grep -v '^$' | xargs
}

# Fungsi untuk backup database
backup_database() {
    local db_name="$1"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/${db_name}_${timestamp}.sql"
    
    # Tampilkan notifikasi
    notify-send "PostgreSQL Backup" "Memulai backup database: $db_name" -t 3000
    
    # Lakukan backup
    if sudo -u postgres pg_dump "$db_name" > "$backup_file" 2>/dev/null; then
        # Kompres file backup
        gzip "$backup_file"
        log_message "Backup berhasil: $db_name -> ${backup_file}.gz"
        notify-send "PostgreSQL Backup" "Backup berhasil!\n$db_name\n$(du -h ${backup_file}.gz | cut -f1)" -t 5000
        rofi -e "Backup berhasil!\n\nDatabase: $db_name\nFile: ${backup_file}.gz\nUkuran: $(du -h ${backup_file}.gz | cut -f1)"
    else
        log_message "Backup gagal: $db_name"
        notify-send "PostgreSQL Backup" "Backup gagal: $db_name" -u critical -t 5000
        rofi -e "Backup gagal!\n\nDatabase: $db_name\nSilakan cek log untuk detail."
    fi
}

# Fungsi untuk backup semua database
backup_all_databases() {
    local databases=$(get_databases)
    local count=0
    
    notify-send "PostgreSQL Backup" "Memulai backup semua database..." -t 3000
    
    for db in $databases; do
        local timestamp=$(date '+%Y%m%d_%H%M%S')
        local backup_file="$BACKUP_DIR/${db}_${timestamp}.sql"
        
        if sudo -u postgres pg_dump "$db" > "$backup_file" 2>/dev/null; then
            gzip "$backup_file"
            log_message "Backup berhasil: $db -> ${backup_file}.gz"
            ((count++))
        else
            log_message "Backup gagal: $db"
        fi
    done
    
    notify-send "PostgreSQL Backup" "Backup selesai!\n$count database berhasil di-backup" -t 5000
    rofi -e "Backup semua database selesai!\n\n$count database berhasil di-backup\nLokasi: $BACKUP_DIR"
}

# Fungsi untuk mendapatkan daftar file backup
get_backup_files() {
    find "$BACKUP_DIR" -name "*.sql.gz" -type f -printf "%f\n" | sort -r
}

# Fungsi untuk restore database
restore_database() {
    local backup_file="$1"
    local full_path="$BACKUP_DIR/$backup_file"
    
    # Extract nama database dari nama file
    local db_name=$(echo "$backup_file" | sed 's/_[0-9]*_[0-9]*\.sql\.gz$//')
    
    # Konfirmasi restore
    echo -e "Ya\nTidak" | rofi -dmenu -p "Restore $db_name dari $backup_file? " > /tmp/rofi_confirm
    local confirm=$(cat /tmp/rofi_confirm)
    
    if [ "$confirm" = "Ya" ]; then
        notify-send "PostgreSQL Restore" "Memulai restore database: $db_name" -t 3000
        
        # Decompress dan restore
        if gunzip -c "$full_path" | sudo -u postgres psql "$db_name" > /dev/null 2>&1; then
            log_message "Restore berhasil: $db_name dari $backup_file"
            notify-send "PostgreSQL Restore" "Restore berhasil!\nDatabase: $db_name" -t 5000
            rofi -e "Restore berhasil!\n\nDatabase: $db_name\nDari file: $backup_file"
        else
            log_message "Restore gagal: $db_name dari $backup_file"
            notify-send "PostgreSQL Restore" "Restore gagal: $db_name" -u critical -t 5000
            rofi -e "Restore gagal!\n\nDatabase: $db_name\nFile: $backup_file\n\nCek apakah database sudah ada atau ada masalah dengan file backup."
        fi
    fi
    
    rm -f /tmp/rofi_confirm
}

# Fungsi untuk membuat database baru untuk restore
restore_to_new_database() {
    local backup_file="$1"
    local full_path="$BACKUP_DIR/$backup_file"
    
    # Minta nama database baru
    local new_db=$(rofi -dmenu -p "Nama database baru: ")
    
    if [ -n "$new_db" ]; then
        notify-send "PostgreSQL Restore" "Membuat database baru: $new_db" -t 3000
        
        # Buat database baru
        if sudo -u postgres createdb "$new_db" 2>/dev/null; then
            # Restore ke database baru
            if gunzip -c "$full_path" | sudo -u postgres psql "$new_db" > /dev/null 2>&1; then
                log_message "Restore ke database baru berhasil: $new_db dari $backup_file"
                notify-send "PostgreSQL Restore" "Restore berhasil!\nDatabase baru: $new_db" -t 5000
                rofi -e "Restore berhasil!\n\nDatabase baru: $new_db\nDari file: $backup_file"
            else
                log_message "Restore ke database baru gagal: $new_db"
                sudo -u postgres dropdb "$new_db" 2>/dev/null
                notify-send "PostgreSQL Restore" "Restore gagal!" -u critical -t 5000
                rofi -e "Restore gagal!\n\nGagal restore data ke database: $new_db"
            fi
        else
            log_message "Gagal membuat database: $new_db"
            rofi -e "Gagal membuat database!\n\nDatabase mungkin sudah ada atau nama tidak valid."
        fi
    fi
}

# Fungsi untuk menghapus file backup
delete_backup() {
    local backup_file="$1"
    local full_path="$BACKUP_DIR/$backup_file"
    
    # Konfirmasi hapus
    echo -e "Ya\nTidak" | rofi -dmenu -p "Hapus backup $backup_file? " > /tmp/rofi_confirm
    local confirm=$(cat /tmp/rofi_confirm)
    
    if [ "$confirm" = "Ya" ]; then
        if rm "$full_path" 2>/dev/null; then
            log_message "Backup dihapus: $backup_file"
            notify-send "PostgreSQL Backup" "Backup dihapus: $backup_file" -t 3000
            rofi -e "Backup berhasil dihapus!\n\n$backup_file"
        else
            rofi -e "Gagal menghapus backup!\n\n$backup_file"
        fi
    fi
    
    rm -f /tmp/rofi_confirm
}

# Menu utama
show_main_menu() {
    local choice=$(echo -e "📦 Backup Database\n📦 Backup Semua Database\n♻️  Restore Database\n♻️  Restore ke Database Baru\n🗑️  Hapus File Backup\n📁 Buka Folder Backup\n📊 Lihat Log\n❌ Keluar" | rofi -dmenu -i -p "PostgreSQL Manager" -format s)
    
    case "$choice" in
        "📦 Backup Database")
            local databases=$(get_databases)
            if [ -z "$databases" ]; then
                rofi -e "Tidak ada database yang ditemukan!"
                return
            fi
            local selected_db=$(echo "$databases" | tr ' ' '\n' | rofi -dmenu -i -p "Pilih database untuk backup")
            if [ -n "$selected_db" ]; then
                backup_database "$selected_db"
            fi
            ;;
        "📦 Backup Semua Database")
            backup_all_databases
            ;;
        "♻️  Restore Database")
            local backup_files=$(get_backup_files)
            if [ -z "$backup_files" ]; then
                rofi -e "Tidak ada file backup yang ditemukan!"
                return
            fi
            local selected_file=$(echo "$backup_files" | rofi -dmenu -i -p "Pilih file backup untuk restore")
            if [ -n "$selected_file" ]; then
                restore_database "$selected_file"
            fi
            ;;
        "♻️  Restore ke Database Baru")
            local backup_files=$(get_backup_files)
            if [ -z "$backup_files" ]; then
                rofi -e "Tidak ada file backup yang ditemukan!"
                return
            fi
            local selected_file=$(echo "$backup_files" | rofi -dmenu -i -p "Pilih file backup untuk restore")
            if [ -n "$selected_file" ]; then
                restore_to_new_database "$selected_file"
            fi
            ;;
        "🗑️  Hapus File Backup")
            local backup_files=$(get_backup_files)
            if [ -z "$backup_files" ]; then
                rofi -e "Tidak ada file backup yang ditemukan!"
                return
            fi
            local selected_file=$(echo "$backup_files" | rofi -dmenu -i -p "Pilih file backup untuk dihapus")
            if [ -n "$selected_file" ]; then
                delete_backup "$selected_file"
            fi
            ;;
        "📁 Buka Folder Backup")
            xdg-open "$BACKUP_DIR" 2>/dev/null || nautilus "$BACKUP_DIR" 2>/dev/null || thunar "$BACKUP_DIR" 2>/dev/null
            ;;
        "📊 Lihat Log")
            if [ -f "$LOG_FILE" ]; then
                tail -n 50 "$LOG_FILE" | rofi -dmenu -i -p "Log (50 baris terakhir)" -no-custom
            else
                rofi -e "File log belum ada!"
            fi
            ;;
        "❌ Keluar")
            exit 0
            ;;
    esac
}

# Main loop
while true; do
    show_main_menu
done

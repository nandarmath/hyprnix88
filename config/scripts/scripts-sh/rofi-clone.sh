#!/usr/bin/env bash

# Script untuk copy file/folder antara lokal dan cloud menggunakan rclone dengan rofi
# Pastikan rclone sudah dikonfigurasi dengan 'rclone config'

# Fungsi untuk menampilkan notifikasi
notify() {
    notify-send "Rclone Copy" "$1"
}

# Fungsi untuk memilih remote rclone
select_remote() {
    rclone listremotes | rofi -dmenu -i -p "Pilih Remote Cloud:"
}

# Fungsi untuk browse dan pilih folder/file lokal
browse_local() {
    local current_dir="${1:-$HOME}"
    
    # Normalisasi path
    current_dir=$(realpath "$current_dir" 2>/dev/null || echo "$current_dir")
    
    # List items di direktori current
    local items=""
    
    # Tambahkan opsi khusus
    items+="✅ [Pilih folder ini]\n"
    
    # Tambahkan parent directory jika bukan root
    if [ "$current_dir" != "/" ]; then
        items+="📁 ..\n"
    fi
    
    # List semua directories terlebih dahulu
    while IFS= read -r dir; do
        [ -z "$dir" ] && continue
        items+="📁 $(basename "$dir")/\n"
    done < <(find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir" 2>/dev/null | sort)
    
    # List semua files
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        items+="📄 $(basename "$file")\n"
    done < <(find "$current_dir" -maxdepth 1 -type f 2>/dev/null | sort)
    
    # Tampilkan dengan rofi
    local selected=$(echo -e "$items" | rofi -dmenu -i -p "Browse: $current_dir" -mesg "Pilih file/folder atau navigate")
    
    if [ -z "$selected" ]; then
        # User cancel
        echo ""
        return
    elif [ "$selected" = "✅ [Pilih folder ini]" ]; then
        # Pilih direktori current
        echo "$current_dir"
        return
    elif [ "$selected" = "📁 .." ]; then
        # Naik ke parent directory
        browse_local "$(dirname "$current_dir")"
        return
    else
        # Hapus emoji dan trailing slash
        local clean_name=$(echo "$selected" | sed 's/^[📁📄] //' | sed 's/\/$//')
        local full_path="$current_dir/$clean_name"
        
        if [ -d "$full_path" ]; then
            # Jika directory, masuk ke dalamnya
            browse_local "$full_path"
        elif [ -f "$full_path" ]; then
            # Jika file, return path file
            echo "$full_path"
        fi
    fi
}

# Fungsi untuk browse folder di remote
browse_remote() {
    local remote=$1
    local current_path=$2
    
    # Normalisasi path
    [ "$current_path" = "/" ] && current_path=""
    
    # List direktori dan file di remote
    local dirs=$(rclone lsf "$remote$current_path" --dirs-only 2>/dev/null | sed 's|^|📁 |')
    local files=$(rclone lsf "$remote$current_path" --files-only 2>/dev/null | sed 's|^|📄 |')
    
    # Tambahkan opsi navigasi
    local options="✅ [Pilih folder ini]"
    
    # Tambahkan parent jika bukan root
    if [ -n "$current_path" ]; then
        options+="\n📁 .."
    fi
    
    # Tambahkan dirs dan files
    [ -n "$dirs" ] && options+="\n$dirs"
    [ -n "$files" ] && options+="\n$files"
    
    local selected=$(echo -e "$options" | rofi -dmenu -i -p "Browse: $remote$current_path" -mesg "Pilih file/folder atau navigate")
    
    if [ -z "$selected" ]; then
        # User cancel
        echo ""
        return
    elif [ "$selected" = "✅ [Pilih folder ini]" ]; then
        echo "$current_path"
        return
    elif [ "$selected" = "📁 .." ]; then
        # Naik satu level
        local parent=$(dirname "$current_path")
        [ "$parent" = "." ] && parent=""
        browse_remote "$remote" "$parent"
        return
    else
        # Hapus emoji dan trailing slash
        local clean_name=$(echo "$selected" | sed 's/^[📁📄] //' | sed 's/\/$//')
        
        # Check apakah directory atau file
        if echo "$selected" | grep -q "^📁"; then
            # Masuk ke folder
            if [ -z "$current_path" ]; then
                browse_remote "$remote" "$clean_name/"
            else
                browse_remote "$remote" "$current_path$clean_name/"
            fi
        else
            # File dipilih, return dengan path file
            if [ -z "$current_path" ]; then
                echo "$clean_name"
            else
                echo "$current_path$clean_name"
            fi
        fi
    fi
}

# Menu utama
main_menu() {
    local choice=$(echo -e "☁️ Upload (Lokal → Cloud)\n📥 Download (Cloud → Lokal)" | \
        rofi -dmenu -i -p "Pilih Aksi:")
    
    case "$choice" in
        "☁️ Upload (Lokal → Cloud)")
            upload_to_cloud
            ;;
        "📥 Download (Cloud → Lokal)")
            download_from_cloud
            ;;
    esac
}

# Fungsi upload ke cloud
upload_to_cloud() {
    # Browse dan pilih file/folder lokal
    notify "Pilih file/folder untuk di-upload..."
    local source=$(browse_local "$HOME")
    
    if [ -z "$source" ]; then
        notify "Upload dibatalkan"
        return
    fi
    
    if [ ! -e "$source" ]; then
        notify "Error: Path tidak ditemukan: $source"
        return
    fi
    
    # Pilih remote
    local remote=$(select_remote)
    if [ -z "$remote" ]; then
        notify "Upload dibatalkan"
        return
    fi
    
    # Browse dan pilih destination di remote
    notify "Pilih folder tujuan di cloud..."
    local dest_path=$(browse_remote "$remote" "")
    if [ -z "$dest_path" ] && [ "$dest_path" != "CANCELLED" ]; then
        dest_path="/"
    fi
    
    # Konfirmasi
    local source_name=$(basename "$source")
    local confirm=$(echo -e "Ya\nTidak" | rofi -dmenu -i -p "Upload '$source_name' ke $remote$dest_path?")
    
    if [ "$confirm" = "Ya" ]; then
        notify "Memulai upload '$source_name'..."
        
        # Jalankan rclone di background dengan progress
        if [ -d "$source" ]; then
            # Jika folder, gunakan sync dengan --update untuk hanya copy file baru/berbeda
            # --update: skip files yang lebih lama atau sama
            # --no-update-modtime: jangan update modtime jika file sama
            (rclone copy "$source" "$remote$dest_path$source_name" -P --update --ignore-existing=false && \
             notify "✅ Upload selesai: $source_name (hanya file baru/berbeda)") &
        else
            # Jika file, cek dulu apakah sudah ada
            local dest_file="$remote$dest_path$source_name"
            if rclone lsf "$dest_file" &>/dev/null; then
                # File sudah ada, bandingkan
                (rclone copyto "$source" "$dest_file" -P --update && \
                 notify "✅ Upload selesai: $source_name (file di-update jika berbeda)") &
            else
                # File belum ada, upload
                (rclone copyto "$source" "$dest_file" -P && \
                 notify "✅ Upload selesai: $source_name") &
            fi
        fi
        
        local pid=$!
        notify "Upload berjalan di background (PID: $pid)"
    else
        notify "Upload dibatalkan"
    fi
}

# Fungsi download dari cloud
download_from_cloud() {
    # Pilih remote
    local remote=$(select_remote)
    if [ -z "$remote" ]; then
        notify "Download dibatalkan"
        return
    fi
    
    # Browse dan pilih folder/file di remote
    notify "Pilih file/folder untuk di-download..."
    local source_path=$(browse_remote "$remote" "")
    if [ -z "$source_path" ]; then
        notify "Download dibatalkan"
        return
    fi
    
    # Browse dan pilih destination lokal
    notify "Pilih folder tujuan lokal..."
    local dest=$(browse_local "$HOME")
    
    if [ -z "$dest" ]; then
        notify "Download dibatalkan"
        return
    fi
    
    # Pastikan dest adalah direktori
    if [ -f "$dest" ]; then
        dest=$(dirname "$dest")
    fi
    
    # Buat direktori jika belum ada
    mkdir -p "$dest"
    
    # Konfirmasi
    local source_name=$(basename "$source_path")
    local confirm=$(echo -e "Ya\nTidak" | rofi -dmenu -i -p "Download '$source_name' ke $dest?")
    
    if [ "$confirm" = "Ya" ]; then
        notify "Memulai download '$source_name'..."
        
        # Jalankan rclone di background dengan --update untuk hanya download file baru/berbeda
        (rclone copy "$remote$source_path" "$dest" -P --update --ignore-existing=false && \
         notify "✅ Download selesai: $source_name (hanya file baru/berbeda)") &
        
        local pid=$!
        notify "Download berjalan di background (PID: $pid)"
    else
        notify "Download dibatalkan"
    fi
}

# Cek apakah rclone terinstall
if ! command -v rclone &> /dev/null; then
    notify "Error: rclone tidak ditemukan. Install dengan: sudo pacman -S rclone"
    exit 1
fi

# Cek apakah ada remote yang dikonfigurasi
if [ -z "$(rclone listremotes)" ]; then
    notify "Error: Belum ada remote yang dikonfigurasi. Jalankan: rclone config"
    exit 1
fi

# Jalankan menu utama
main_menu

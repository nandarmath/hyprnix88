#!/usr/bin/env bash

#=============================================================================
# Script: Internet Speed Test with Rofi
# Deskripsi: Mengukur kecepatan internet dengan interface Rofi
# Author: Linux Professional
# Versi: 2.0
#=============================================================================

# Konfigurasi Rofi
ROFI_THEME="~/.config/rofi/speedtest.rasi"
ROFI_CMD="rofi -dmenu -i -p"

# File untuk menyimpan hasil sementara
TEMP_RESULT="/tmp/speedtest_result.txt"
LOG_FILE="$HOME/.speedtest_history.log"

# Fungsi untuk menampilkan notifikasi
notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send &> /dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    fi
}

# Fungsi untuk cek koneksi
check_connection() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        notify "Speed Test" "Tidak ada koneksi internet!" "critical"
        echo "❌ Tidak ada koneksi internet" | $ROFI_CMD "Error"
        exit 1
    fi
}

# Fungsi untuk mendapatkan info jaringan
get_network_info() {
    local public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "N/A")
    local active_if=$(ip route | grep default | awk '{print $5}' | head -n1)
    local local_ip=$(ip addr show $active_if 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    local ping_avg=$(ping -c 4 8.8.8.8 2>/dev/null | tail -1 | awk -F'/' '{print $5}' | cut -d'.' -f1)
    
    echo "🌐 IP Publik: $public_ip"
    echo "🖥️  IP Lokal: $local_ip"
    echo "📡 Interface: $active_if"
    echo "⚡ Ping: ${ping_avg}ms"
}

# Fungsi speedtest-cli dengan progress
speedtest_cli_test() {
    notify "Speed Test" "Memulai pengukuran kecepatan..." "normal"
    
    if ! command -v speedtest-cli &> /dev/null; then
        echo "❌ speedtest-cli tidak terinstall" > "$TEMP_RESULT"
        echo "" >> "$TEMP_RESULT"
        echo "Install dengan:" >> "$TEMP_RESULT"
        echo "sudo apt install speedtest-cli" >> "$TEMP_RESULT"
        echo "atau: pip install speedtest-cli" >> "$TEMP_RESULT"
        return 1
    fi
    
    # Terminal untuk menampilkan progress
    terminal_cmd="alacritty"
    
    # Deteksi terminal yang tersedia
    for term in kitty alacritty termite urxvt xterm gnome-terminal; do
        if command -v $term &> /dev/null; then
            terminal_cmd=$term
            break
        fi
    done
    
    # Jalankan speedtest di terminal
    case $terminal_cmd in
        kitty|alacritty|termite)
            $terminal_cmd -e bash -c "
                echo '═══════════════════════════════════════'
                echo '     INTERNET SPEED TEST'
                echo '═══════════════════════════════════════'
                echo ''
                speedtest-cli
                echo ''
                echo '═══════════════════════════════════════'
                echo 'Tekan Enter untuk melanjutkan...'
                read
            " &
            ;;
        *)
            $terminal_cmd -e "bash -c \"
                echo '═══════════════════════════════════════'
                echo '     INTERNET SPEED TEST'
                echo '═══════════════════════════════════════'
                echo ''
                speedtest-cli
                echo ''
                echo '═══════════════════════════════════════'
                echo 'Tekan Enter untuk melanjutkan...'
                read
            \"" &
            ;;
    esac
    
    wait
    
    # Simpan hasil ke log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Speedtest-cli executed" >> "$LOG_FILE"
    
    notify "Speed Test" "Pengukuran selesai!" "normal"
}

# Fungsi curl download test
curl_download_test() {
    notify "Speed Test" "Mengukur kecepatan download..." "normal"
    
    echo "⏳ Sedang mengukur..." > "$TEMP_RESULT"
    
    test_urls=(
        "http://speedtest.tele2.net/10MB.zip"
        "http://mirror.wdc1.us.leaseweb.net/speedtest/10mb.bin"
    )
    
    echo "📊 DOWNLOAD SPEED TEST" > "$TEMP_RESULT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$TEMP_RESULT"
    echo "" >> "$TEMP_RESULT"
    
    for url in "${test_urls[@]}"; do
        speed=$(curl -o /dev/null -s -w '%{speed_download}' --max-time 30 "$url" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ ! -z "$speed" ]; then
            speed_int=$(echo "$speed" | cut -d'.' -f1)
            
            # Konversi ke MB/s dan Mbps
            mb_s=$(echo "scale=2; $speed / 1048576" | bc)
            mbps=$(echo "scale=2; $speed * 8 / 1000000" | bc)
            
            echo "📥 Download: $mb_s MB/s" >> "$TEMP_RESULT"
            echo "⚡ Kecepatan: $mbps Mbps" >> "$TEMP_RESULT"
            echo "" >> "$TEMP_RESULT"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Download: $mbps Mbps" >> "$LOG_FILE"
            break
        fi
    done
    
    cat "$TEMP_RESULT" | $ROFI_CMD "Hasil Test" -lines 10
    notify "Speed Test" "Download test selesai: $mbps Mbps" "normal"
}

# Fungsi wget download test
wget_download_test() {
    notify "Speed Test" "Mengukur dengan wget..." "normal"
    
    test_url="http://speedtest.tele2.net/10MB.zip"
    
    # Terminal untuk progress
    terminal_cmd="kitty"
    for term in kitty alacritty termite urxvt xterm gnome-terminal; do
        if command -v $term &> /dev/null; then
            terminal_cmd=$term
            break
        fi
    done
    
    case $terminal_cmd in
        kitty|alacritty|termite)
            $terminal_cmd -e bash -c "
                echo '═══════════════════════════════════════'
                echo '     WGET DOWNLOAD TEST'
                echo '═══════════════════════════════════════'
                echo ''
                wget --output-document=/dev/null '$test_url'
                echo ''
                echo '═══════════════════════════════════════'
                echo 'Tekan Enter untuk melanjutkan...'
                read
            " &
            ;;
        *)
            $terminal_cmd -e "bash -c \"
                echo '═══════════════════════════════════════'
                echo '     WGET DOWNLOAD TEST'
                echo '═══════════════════════════════════════'
                echo ''
                wget --output-document=/dev/null '$test_url'
                echo ''
                echo '═══════════════════════════════════════'
                echo 'Tekan Enter untuk melanjutkan...'
                read
            \"" &
            ;;
    esac
    
    wait
    notify "Speed Test" "Wget test selesai!" "normal"
}

# Fungsi untuk menampilkan info jaringan di rofi
show_network_info() {
    echo "⏳ Mengambil informasi jaringan..." | $ROFI_CMD "Network Info"
    
    get_network_info > "$TEMP_RESULT"
    
    cat "$TEMP_RESULT" | $ROFI_CMD "Informasi Jaringan" -lines 10
}

# Fungsi untuk melihat history
show_history() {
    if [ -f "$LOG_FILE" ]; then
        tail -20 "$LOG_FILE" | $ROFI_CMD "History" -lines 20
    else
        echo "📝 Belum ada history" | $ROFI_CMD "History"
    fi
}

# Fungsi untuk menampilkan semua hasil
run_all_tests() {
    notify "Speed Test" "Menjalankan semua test..." "normal"
    speedtest_cli_test
    sleep 2
    curl_download_test
}

# Menu utama
show_menu() {
    check_connection
    
    options=(
        "🚀 Speedtest-cli (Recommended)"
        "📥 Download Test (curl)"
        "📊 Download Test (wget)"
        "🔄 Jalankan Semua Test"
        "🌐 Info Jaringan"
        "📜 Lihat History"
        "❌ Keluar"
    )
    
    # Tampilkan menu dengan rofi
    choice=$(printf '%s\n' "${options[@]}" | $ROFI_CMD "Speed Test Menu" -lines 7 -width 40)
    
    case "$choice" in
        "${options[0]}")
            speedtest_cli_test
            show_menu
            ;;
        "${options[1]}")
            curl_download_test
            show_menu
            ;;
        "${options[2]}")
            wget_download_test
            show_menu
            ;;
        "${options[3]}")
            run_all_tests
            show_menu
            ;;
        "${options[4]}")
            show_network_info
            show_menu
            ;;
        "${options[5]}")
            show_history
            show_menu
            ;;
        "${options[6]}")
            notify "Speed Test" "Terima kasih!" "normal"
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
}

# Cleanup saat exit
cleanup() {
    rm -f "$TEMP_RESULT"
}

trap cleanup EXIT

# Jalankan menu
show_menu

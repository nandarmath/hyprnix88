#!/usr/bin/env bash

# Script untuk menampilkan informasi IP menggunakan rofi
# Tidak memerlukan dependency eksternal selain rofi dan tools standar Linux

# Fungsi untuk menampilkan notifikasi
notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "IP Info" "$1"
    else
        echo "$1"
    fi
}

# Fungsi untuk copy ke clipboard
copy_to_clipboard() {
    if command -v xclip &> /dev/null; then
        echo -n "$1" | xclip -selection clipboard
        notify "Disalin ke clipboard: $1"
    elif command -v xsel &> /dev/null; then
        echo -n "$1" | xsel --clipboard
        notify "Disalin ke clipboard: $1"
    else
        notify "Clipboard tool tidak tersedia (install xclip atau xsel)"
    fi
}

# Fungsi untuk mendapatkan IP lokal
get_local_ip() {
    local ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
    echo "${ip:-Tidak ditemukan}"
}

# Fungsi untuk mendapatkan IP publik
get_public_ip() {
    local ip=$(curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipecho.net/plain)
    echo "${ip:-Gagal mendapatkan IP publik}"
}

# Fungsi untuk mendapatkan semua interface dan IP
get_all_interfaces() {
    ip -4 addr show | awk '/^[0-9]+:/ {iface=$2; sub(/:$/, "", iface)} /inet / && !/127.0.0.1/ {print iface ": " $2}' | sed 's|/.*||'
}

# Fungsi untuk mendapatkan gateway
get_gateway() {
    local gw=$(ip route | grep default | awk '{print $3}' | head -n1)
    echo "${gw:-Tidak ditemukan}"
}

# Fungsi untuk mendapatkan DNS server
get_dns() {
    if [[ -f /etc/resolv.conf ]]; then
        grep -i '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//'
    else
        echo "Tidak ditemukan"
    fi
}

# Menu utama
main_menu() {
    echo "📍 IP Lokal"
    echo "🌐 IP Publik"
    echo "🖧 Semua Interface"
    echo "🚪 Gateway"
    echo "🔍 DNS Server"
    echo "📋 Info Lengkap"
    echo "❌ Keluar"
}

# Tampilkan info lengkap
show_full_info() {
    local info="=== INFORMASI JARINGAN ===\n\n"
    info+="IP Lokal: $(get_local_ip)\n"
    info+="IP Publik: $(get_public_ip)\n\n"
    info+="Gateway: $(get_gateway)\n"
    info+="DNS: $(get_dns)\n\n"
    info+="=== SEMUA INTERFACE ===\n"
    info+="$(get_all_interfaces)\n"
    
    echo -e "$info" | rofi -dmenu -p "Info Jaringan" -mesg "Tekan Esc untuk kembali"
}

# Main loop
while true; do
    choice=$(main_menu | rofi -dmenu -i -p "Pilih Info IP" -theme-str 'window {width: 400px;}')
    
    case "$choice" in
        "📍 IP Lokal")
            ip=$(get_local_ip)
            action=$(echo -e "📋 Copy\n👁 Tampilkan\n← Kembali" | rofi -dmenu -p "IP Lokal: $ip")
            case "$action" in
                "📋 Copy") copy_to_clipboard "$ip" ;;
                "👁 Tampilkan") notify "IP Lokal: $ip" ;;
            esac
            ;;
        "🌐 IP Publik")
            ip=$(get_public_ip)
            action=$(echo -e "📋 Copy\n👁 Tampilkan\n← Kembali" | rofi -dmenu -p "IP Publik: $ip")
            case "$action" in
                "📋 Copy") copy_to_clipboard "$ip" ;;
                "👁 Tampilkan") notify "IP Publik: $ip" ;;
            esac
            ;;
        "🖧 Semua Interface")
            get_all_interfaces | rofi -dmenu -p "Semua Interface" -mesg "Tekan Esc untuk kembali"
            ;;
        "🚪 Gateway")
            gw=$(get_gateway)
            action=$(echo -e "📋 Copy\n👁 Tampilkan\n← Kembali" | rofi -dmenu -p "Gateway: $gw")
            case "$action" in
                "📋 Copy") copy_to_clipboard "$gw" ;;
                "👁 Tampilkan") notify "Gateway: $gw" ;;
            esac
            ;;
        "🔍 DNS Server")
            dns=$(get_dns)
            action=$(echo -e "📋 Copy\n👁 Tampilkan\n← Kembali" | rofi -dmenu -p "DNS: $dns")
            case "$action" in
                "📋 Copy") copy_to_clipboard "$dns" ;;
                "👁 Tampilkan") notify "DNS Server: $dns" ;;
            esac
            ;;
        "📋 Info Lengkap")
            show_full_info
            ;;
        "❌ Keluar"|"")
            exit 0
            ;;
    esac
done

#!/bin/bash
# File              : hypr_dmenu_aria2
# License           : MIT License
# Description       : Aria2 download script untuk Hyprland
# Required packages:
# 1. aria2p (https://github.com/pawamoy/aria2p)
# 2. wofi atau rofi (untuk menu selector di Wayland)
# 3. cliphist atau wl-clipboard (untuk clipboard manager di Wayland)
# 4. jq (untuk JSON processing)
# 5. notify-send/mako/dunst (untuk notifikasi)

# Konfigurasi
ARIA2URI="http://localhost:6800/jsonrpc"

# Pilih menu launcher (prioritas: wofi > rofi > bemenu)
if command -v rofi &> /dev/null; then
    DMENU="rofi -dmenu -i -p Download"
elif command -v wofi &> /dev/null; then
    DMENU="wofi --dmenu --insensitive --prompt 'Download'"
elif command -v bemenu &> /dev/null; then
    DMENU="bemenu -i -p 'Download:'"
else
    notify-send "Error" "Tidak ada menu launcher (wofi/rofi/bemenu) yang terinstall!" -u critical
    exit 1
fi

# Fungsi untuk generate JSON-RPC request
function datagen() {
    jq -n --arg id "$(date +%N)" --arg url "$1" \
        '{ "jsonrpc": "2.0", "id": $id, "method":"aria2.addUri", "params":[[$url]] }'
}

# Fungsi untuk mendapatkan URL dari clipboard
function get_clipboard_urls() {
    # Cek apakah menggunakan cliphist (recommended untuk Hyprland)
    if command -v cliphist &> /dev/null; then
        cliphist list | grep -Po '(http|https|ftp|ftps):\/\/[^\s]+' | awk '!seen[$0]++'
    # Fallback ke wl-paste jika cliphist tidak tersedia
    elif command -v wl-paste &> /dev/null; then
        wl-paste -l 2>/dev/null | while read -r mime; do
            wl-paste -t "$mime" 2>/dev/null
        done | grep -Po '(http|https|ftp|ftps):\/\/[^\s]+' | awk '!seen[$0]++'
    # Fallback terakhir: baca langsung dari wl-paste
    else
        wl-paste 2>/dev/null | grep -Po '(http|https|ftp|ftps):\/\/[^\s]+' | head -1
    fi
}

# Dapatkan URL dari clipboard
url=$(get_clipboard_urls | eval $DMENU)

# Jika user memilih URL, mulai download
if [[ ! -z "$url" ]]; then
    # Kirim notifikasi
    notify-send "Aria2 | Downloading" "$url" -u normal -t 3000
    
    # Generate data JSON dan kirim ke aria2
    data=$(datagen "$url")
    response=$(curl -s --request POST --url "$ARIA2URI" \
        --header 'Content-Type: application/json' \
        --data "$data")
    
    # Cek apakah download berhasil ditambahkan
    if echo "$response" | jq -e '.result' &> /dev/null; then
        gid=$(echo "$response" | jq -r '.result')
        notify-send "Aria2 | Success" "Download ditambahkan (GID: $gid)" -u low -t 2000
    else
        error=$(echo "$response" | jq -r '.error.message // "Unknown error"')
        notify-send "Aria2 | Error" "$error" -u critical -t 5000
    fi
fi

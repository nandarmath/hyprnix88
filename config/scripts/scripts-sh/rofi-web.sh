#!/usr/bin/env bash

# Rofi DuckDuckGo Web Search Script
# Meminta input dari user menggunakan rofi dan membuka hasil pencarian di browser

# Konfigurasi
BROWSER="${BROWSER:-xdg-open}"  # Default browser, bisa diganti dengan firefox, chromium, dll
SEARCH_ENGINE="https://duckduckgo.com/?q="

# Prompt untuk input pencarian
query=$(rofi -dmenu -p " 󰜏 " -theme-str 'window {width: 35%; height:5%;}')

# Cek apakah user memasukkan query
if [ -z "$query" ]; then
    exit 0
fi

# Encode URL (ganti spasi dengan +)
encoded_query=$(echo "$query" | sed 's/ /+/g')

# Buka browser dengan hasil pencarian
$BROWSER "${SEARCH_ENGINE}${encoded_query}"

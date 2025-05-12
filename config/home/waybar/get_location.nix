#!/bin/bash
{pkgs}:
pkgs.writeShellScriptBin "get_location" ''


# Script untuk menetapkan lokasi waktu sholat secara manual
# Simpan script ini di ~/.config/waybar/scripts/

CACHE_DIR="$HOME/.cache/prayer_times"
LOCATION_CACHE="$CACHE_DIR/location.json"

# Membuat`` direktori cache jika belum ada
mkdir -p "$CACHE_DIR"

# Fungsi untuk menampilkan daftar kota dan meminta pilihan
select_city() {
    echo "Pilih kota/kabupaten:"
    echo "1) Yogyakarta"
    echo "2) Sleman"
    echo "3) Bantul"
    echo "4) Kulon Progo"
    echo "5) Gunungkidul"
    echo "6) Magelang"
    echo "7) Klaten"
    echo "8) Jakarta"
    echo "9) Surabaya"
    echo "10) Kota lain (input manual)"
    
    read -p "Pilihan (1-10): " choice
    
    case $choice in
        1)
            set_location "Yogyakarta" "Yogyakarta" "-7.7956,110.3695"
            ;;
        2)
            set_location "Sleman" "Yogyakarta" "-7.7167,110.3500"
            ;;
        3)
            set_location "Bantul" "Yogyakarta" "-7.8887,110.3331"
            ;;
        4)
            set_location "Kulon Progo" "Yogyakarta" "-7.8268,110.1625"
            ;;
        5)
            set_location "Gunungkidul" "Yogyakarta" "-7.9889,110.6089"
            ;;
        6)
            set_location "Magelang" "Jawa Tengah" "-7.4797,110.2177"
            ;;
        7)
            set_location "Klaten" "Jawa Tengah" "-7.7022,110.6063"
            ;;
        8)
            set_location "Jakarta" "DKI Jakarta" "-6.2088,106.8456"
            ;;
        9)
            set_location "Surabaya" "Jawa Timur" "-7.2575,112.7521"
            ;;
        10)
            manual_input
            ;;
        *)
            echo "Pilihan tidak valid"
            select_city
            ;;
    esac
}

# Fungsi untuk input manual
manual_input() {
    read -p "Nama Kota/Kabupaten: " city
    read -p "Provinsi: " region
    read -p "Latitude (contoh: -7.7956): " lat
    read -p "Longitude (contoh: 110.3695): " lon
    
    set_location "$city" "$region" "$lat,$lon"
}

# Fungsi untuk menetapkan lokasi
set_location() {
    local city="$1"
    local region="$2"
    local loc="$3"
    
    # Membuat file JSON
    echo "{
        \"loc\": \"$loc\",
        \"city\": \"$city\",
        \"region\": \"$region\"
    }" > "$LOCATION_CACHE"
    
    echo "Lokasi berhasil diatur ke $city, $region"
    echo "Koordinat: $loc"
    echo ""
    echo "Silakan restart waybar dengan perintah:"
    echo "killall waybar && waybar &"
}

# Menu utama
echo "==== Setting Lokasi Waktu Sholat ===="
echo "1) Gunakan lokasi berdasarkan IP (otomatis)"
echo "2) Pilih lokasi manual"
read -p "Pilihan (1-2): " main_choice

case $main_choice in
    1)
        # Hapus cache lokasi agar script utama mengambil lokasi baru
        rm -f "$LOCATION_CACHE"
        echo "Lokasi akan dideteksi otomatis berdasarkan IP"
        echo ""
        echo "Silakan restart waybar dengan perintah:"
        echo "killall waybar && waybar &"
        ;;
    2)
        select_city
        ;;
    *)
        echo "Pilihan tidak valid"
        exit 1
        ;;
esac

exit 0
''

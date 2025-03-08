#!/usr/bin/env bash

# Dependensi: rofi, nmcli, awk, grep

# Fungsi untuk menghubungkan ke jaringan
{pkgs}:
pkgs.writeShellScriptBin "rofi-wfi" ''

connect_to_network() {
    local ssid="$1"
    
    # Cek apakah koneksi ke SSID ini sudah ada dalam daftar koneksi tersimpan
    if nmcli -t -f NAME connection show | grep -Fx "$ssid" &>/dev/null; then
        # Gunakan koneksi yang sudah ada (dengan password tersimpan)
        echo "Menggunakan profil tersimpan untuk '$ssid'"
        nmcli connection up id "$ssid"
        return $?
    fi
    
    # Jika tidak ada koneksi tersimpan, cek apakah jaringan memerlukan password
    if nmcli -t -f SSID,SECURITY device wifi list | grep -F "$(echo "$ssid" | sed 's/:/\\:/g'):" | grep -q "WPA"; then
        # Gunakan rofi untuk meminta password
        password=$(rofi -dmenu -p "Password untuk '$ssid'" -password -lines 0)
        
        # Jika pengguna membatalkan input password
        if [[ -z "$password" ]]; then
            return 1
        fi
        
        # Hubungkan ke jaringan dengan password dan simpan ke dalam profil NetworkManager
        nmcli device wifi connect "$ssid" password "$password"
    else
        # Hubungkan ke jaringan tanpa password
        nmcli device wifi connect "$ssid"
    fi
}

# Fungsi untuk menampilkan daftar jaringan dan menangani pilihan
show_wifi_menu() {
    # Dapatkan SSID yang sedang aktif terhubung
    active_device=$(nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1 | head -n1)
    active_connection=$(nmcli -t -f DEVICE,CONNECTION device status | grep "^${active_device}:" | cut -d':' -f2)

    echo "Perangkat aktif: $active_device"
    echo "Koneksi aktif: $active_connection"

    # Ambil daftar SSID yang tersedia beserta kekuatan sinyal dan info keamanan
    networks=$(nmcli --colors no --fields SSID,BARS,SECURITY,IN-USE device wifi list | tail -n +2)

    formatted_networks=""

    # Gunakan IFS untuk membaca berdasarkan baris penuh
    while IFS= read -r line; do
        # Ekstrak SSID dengan menangani spasi dengan benar
        in_use=$(echo "$line" | grep -o "^\*" || echo "")
        line_without_star=${line#\* }
        line_without_star=${line#  }
        
        ssid=$(echo "$line_without_star" | awk -F ' {2,}' '{print $1}')
        signal=$(echo "$line_without_star" | awk -F ' {2,}' '{print $2}')
        security=$(echo "$line_without_star" | awk -F ' {2,}' '{print $3}')
        
        # Skip jaringan dengan SSID kosong
        if [[ -z "$ssid" || "$ssid" == "--" ]]; then
            continue
        fi
        
        # Tandai jaringan yang terhubung dengan label "Connected"
        if [[ -n "$in_use" || "$ssid" == "$active_connection" ]]; then
            formatted_networks+="$ssid [Connected] ∷ $signal ∷ $security\n"
        else
            formatted_networks+="$ssid ∷ $signal ∷ $security\n"
        fi
    done <<< "$networks"

    # Tambahkan opsi untuk memindai ulang dan mengelola koneksi tersimpan
    formatted_networks+="[Pindai Ulang Jaringan WiFi]\n"
    formatted_networks+="[Kelola Koneksi Tersimpan]"

    # Tampilkan menu rofi
    chosen_network=$(echo -e "$formatted_networks" | rofi -dmenu -i -p "Pilih Jaringan WiFi" -lines 15 -width 40)

    # Jika tidak ada yang dipilih (user cancel)
    if [[ -z "$chosen_network" ]]; then
        exit 0
    fi

    # Jika opsi pindai ulang dipilih
    if [[ "$chosen_network" == "[Pindai Ulang Jaringan WiFi]" ]]; then
        echo "Memindai ulang jaringan WiFi..."
        # Pastikan semua perangkat WiFi dipindai
        for wifi_dev in $(nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1); do
            nmcli device wifi rescan ifname "$wifi_dev" &>/dev/null
        done
        # Jika tidak ada perangkat spesifik, lakukan pemindaian umum
        if [ $? -ne 0 ]; then
            nmcli device wifi rescan &>/dev/null
        fi
        
        # Tunggu sebentar untuk memastikan scan selesai
        sleep 2
        notify-send "WiFi" "Pemindaian jaringan selesai"
        
        # Panggil fungsi ini lagi untuk refresh
        show_wifi_menu
        return
    fi

    # Jika opsi kelola koneksi dipilih
    if [[ "$chosen_network" == "[Kelola Koneksi Tersimpan]" ]]; then
        # Ambil daftar koneksi WiFi tersimpan
        saved_connections=$(nmcli -t -f NAME,TYPE connection show | grep ':802-11-wireless$' | cut -d':' -f1)
        
        if [[ -z "$saved_connections" ]]; then
            notify-send "WiFi" "Tidak ada koneksi tersimpan"
            show_wifi_menu
            return
        fi
        
        # Tambahkan opsi kembali
        saved_connections+=$(echo -e "\n[Kembali]")
        
        # Tampilkan daftar koneksi tersimpan
        selected_conn=$(echo -e "$saved_connections" | rofi -dmenu -i -p "Kelola Koneksi Tersimpan" -lines 10)
        
        if [[ -z "$selected_conn" || "$selected_conn" == "[Kembali]" ]]; then
            show_wifi_menu
            return
        fi
        
        # Tanyakan tindakan untuk koneksi tersimpan
        action=$(echo -e "Hubungkan\nLupakan\nKembali" | rofi -dmenu -i -p "Tindakan untuk '$selected_conn'")
        
        case "$action" in
            "Hubungkan")
                nmcli connection up id "$selected_conn"
                if [[ $? -eq 0 ]]; then
                    notify-send "WiFi" "Terhubung ke '$selected_conn'"
                else
                    notify-send "WiFi" "Gagal terhubung ke '$selected_conn'"
                fi
                ;;
            "Lupakan")
                nmcli connection delete id "$selected_conn"
                notify-send "WiFi" "Menghapus koneksi '$selected_conn'"
                ;;
            *)
                show_wifi_menu
                return
                ;;
        esac
        
        show_wifi_menu
        return
    fi

    # Cek apakah jaringan yang dipilih adalah yang sedang terhubung
    if [[ "$chosen_network" == *"[Connected]"* ]]; then
        # Ekstrak SSID dari jaringan terhubung
        selected_ssid=$(echo "$chosen_network" | awk -F ' \[Connected\]' '{print $1}')
        
        # Konfirmasi sebelum memutuskan koneksi
        action=$(echo -e "Putuskan\nBatal" | rofi -dmenu -i -p "Apakah anda ingin memutuskan dari '$selected_ssid'?")
        
        if [[ "$action" == "Putuskan" ]]; then
            # Coba dengan beberapa metode untuk memastikan koneksi terputus
            # Metode 1: Gunakan nama koneksi
            nmcli connection down id "$selected_ssid" 2>/dev/null
            
            # Metode 2: Gunakan nama perangkat wifi
            if [[ -n "$active_device" ]]; then
                nmcli device disconnect "$active_device" 2>/dev/null
            fi
            
            # Metode 3: Coba dengan semua interface wifi yang diketahui
            for dev in $(nmcli -t -f DEVICE,TYPE device status | grep ':wifi$' | cut -d':' -f1); do
                nmcli device disconnect "$dev" 2>/dev/null
            done
            
            notify-send "WiFi" "Terputus dari '$selected_ssid'"
            sleep 1
            
            # Refresh untuk menampilkan status terbaru
            show_wifi_menu
            return
        fi
        
        show_wifi_menu
        return
    else
        # Untuk jaringan yang tidak terhubung, ekstrak SSID
        selected_ssid=$(echo "$chosen_network" | awk -F ' ∷ ' '{print $1}')
    fi

    # Cek apakah koneksi sudah tersimpan
    if nmcli -t -f NAME connection show | grep -Fx "$selected_ssid" &>/dev/null; then
        # Jika koneksi sudah tersimpan, langsung hubungkan
        nmcli connection up id "$selected_ssid"
        
        if [[ $? -eq 0 ]]; then
            notify-send "WiFi" "Terhubung ke '$selected_ssid'"
        else
            # Jika gagal, mungkin password sudah berubah
            action=$(echo -e "Gunakan Password Baru\nLupakan\nKembali" | rofi -dmenu -i -p "Gagal terhubung ke '$selected_ssid'")
            
            case "$action" in
                "Gunakan Password Baru")
                    # Hapus koneksi lama dan buat koneksi baru
                    nmcli connection delete id "$selected_ssid" &>/dev/null
                    connect_to_network "$selected_ssid"
                    
                    if [[ $? -eq 0 ]]; then
                        notify-send "WiFi" "Terhubung ke '$selected_ssid' dengan password baru"
                    else
                        notify-send "WiFi" "Gagal terhubung ke '$selected_ssid'"
                    fi
                    ;;
                "Lupakan")
                    nmcli connection delete id "$selected_ssid"
                    notify-send "WiFi" "Menghapus koneksi '$selected_ssid'"
                    ;;
                *)
                    show_wifi_menu
                    return
                    ;;
            esac
        fi
    else
        # Hubungkan ke jaringan yang belum tersimpan
        connect_to_network "$selected_ssid"
        
        # Menampilkan notifikasi status koneksi
        if [[ $? -eq 0 ]]; then
            notify-send "WiFi" "Terhubung ke '$selected_ssid'"
        else
            notify-send "WiFi" "Gagal terhubung ke '$selected_ssid'"
        fi
    fi
    
    # Kembali ke menu utama setelah melakukan aksi
    sleep 1
    show_wifi_menu
}

# Mulai program
show_wifi_menu

''


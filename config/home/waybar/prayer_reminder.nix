# prayer-reminder.nix
{pkgs ? import <nixpkgs> {}}: let
  prayerReminderScript = pkgs.writeShellScriptBin "prayer_reminder" ''
    #!/bin/bash

    # Script untuk menjalankan notifikasi waktu sholat
    # Simpan di ~/.config/waybar/scripts/prayer-reminder.sh

    CACHE_DIR="$HOME/.cache/prayer_times"
    CACHE_FILE="$CACHE_DIR/prayer_times.json"
    LAST_NOTIF_FILE="$CACHE_DIR/last_notification"
    ADZAN_SOUND="$HOME/.config/waybar/scripts/adzan.mp3"
    ICON_PATH="$HOME/.config/waybar/scripts/mosque.png"

    # Default icon jika tidak ada
    DEFAULT_ICON="/usr/share/icons/Adwaita/32x32/status/dialog-information.png"

    # Gunakan icon default jika custom icon tidak ada
    if [ ! -f "$ICON_PATH" ]; then
        ICON_PATH="$DEFAULT_ICON"
    fi

    # Buat direktori cache jika belum ada
    mkdir -p "$CACHE_DIR"

    # Fungsi untuk memutar adzan
    play_adzan() {
        # Cek apakah mpv tersedia
        if command -v mpv &> /dev/null; then
            # Cek apakah file adzan ada
            if [ -f "$ADZAN_SOUND" ]; then
                mpv "$ADZAN_SOUND" --volume=70 &
            fi
        elif command -v paplay &> /dev/null; then
            # Alternatif menggunakan paplay jika adzan dalam format ogg/wav
            if [ -f "$ADZAN_SOUND" ] && [ "$ADZAN_SOUND" = *.ogg -o "$ADZAN_SOUND" = *.wav ]; then
                paplay "$ADZAN_SOUND" &
            fi
        fi
    }

    # Cek apakah file cache waktu sholat ada
    if [ ! -f "$CACHE_FILE" ]; then
        # Jalankan script utama untuk mendapatkan waktu sholat
        prayer_time > /dev/null

        # Keluar jika masih tidak ada
        if [ ! -f "$CACHE_FILE" ]; then
            exit 1
        fi
    fi

    # Mendapatkan nama lokasi
    location=$(jq -r '.location // "Lokasi tidak diketahui"' "$CACHE_FILE")

    # Mengambil waktu sholat dari cache
    fajr=$(jq -r '.data.timings.Fajr' "$CACHE_FILE")
    dhuhr=$(jq -r '.data.timings.Dhuhr' "$CACHE_FILE")
    asr=$(jq -r '.data.timings.Asr' "$CACHE_FILE")
    maghrib=$(jq -r '.data.timings.Maghrib' "$CACHE_FILE")
    isha=$(jq -r '.data.timings.Isha' "$CACHE_FILE")

    # Mendapatkan waktu sekarang
    current_time=$(date +"%H:%M")
    current_hour=$(date +"%H")
    current_minute=$(date +"%M")

    # Mengambil tanggal hari ini
    current_date=$(date +"%Y-%m-%d")

    # Fungsi untuk memeriksa waktu sholat dan mengirimkan notifikasi
    check_prayer_time() {
        prayer_name="$1"
        prayer_time="$2"

        # Memisahkan jam dan menit dari waktu sholat
        prayer_hour=$(echo "$prayer_time" | cut -d: -f1)
        prayer_minute=$(echo "$prayer_time" | cut -d: -f2)

        # Memeriksa apakah waktu saat ini sama dengan waktu sholat
        if [ "$current_hour" -eq "$prayer_hour" ] && [ "$current_minute" -eq "$prayer_minute" ]; then
            # Periksa apakah notifikasi sudah dikirim hari ini untuk waktu sholat ini
            if [ -f "$LAST_NOTIF_FILE" ]; then
                last_notif=$(cat "$LAST_NOTIF_FILE")
                if [ "$last_notif" = "${current_date}_${prayer_name}" ]; then
                    # Notifikasi sudah dikirim, tidak perlu kirim lagi
                    return
                fi
            fi

            # Kirim notifikasi
            if [ "$prayer_name" = "Subuh" ]; then
                message="Waktu Subuh telah tiba. Sholat Subuh 2 rakaat."
            elif [ "$prayer_name" = "Dzuhur" ]; then
                message="Waktu Dzuhur telah tiba. Sholat Dzuhur 4 rakaat."
            elif [ "$prayer_name" = "Ashar" ]; then
                message="Waktu Ashar telah tiba. Sholat Ashar 4 rakaat."
            elif [ "$prayer_name" = "Maghrib" ]; then
                message="Waktu Maghrib telah tiba. Sholat Maghrib 3 rakaat."
            elif [ "$prayer_name" = "Isya" ]; then
                message="Waktu Isya telah tiba. Sholat Isya 4 rakaat."
            fi

            # Mengirim notifikasi desktop
            notify-send -i "$ICON_PATH" "Waktu Sholat $prayer_name ($location)" "$message" -u critical

            # Putar adzan
            play_adzan

            # Catat bahwa notifikasi sudah dikirim
            echo "${current_date}_${prayer_name}" > "$LAST_NOTIF_FILE"
        fi
    }

    # Memeriksa semua waktu sholat
    check_prayer_time "Subuh" "$fajr"
    check_prayer_time "Dzuhur" "$dhuhr"
    check_prayer_time "Ashar" "$asr"
    check_prayer_time "Maghrib" "$maghrib"
    check_prayer_time "Isya" "$isha"

    exit 0
  '';

  # Paket ini membutuhkan dependensi lainnya
  dependencies = with pkgs; [
    jq # Untuk parsing JSON
    libnotify # Untuk notify-send
    mpv # Untuk memutar audio adzan
    pulseaudio # Untuk perintah paplay
  ];
in {
  # Paket utama yang mengandung script
  package = prayerReminderScript;

  # Kita juga bisa membuat derivasi yang menggabungkan script dengan dependensinya
  prayerReminderWithDeps = pkgs.symlinkJoin {
    name = "prayer-reminder-with-deps";
    paths = [prayerReminderScript] ++ dependencies;
  };
}


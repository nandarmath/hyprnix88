{pkgs}:
pkgs.writeShellScriptBin "prayer_time" ''


  #!/bin/bash

  # Script untuk menampilkan waktu sholat di Kabupaten Sleman pada waybar
  # Memanfaatkan API aladhan.com dengan koordinat Kabupaten Sleman
  # Latitude: -7.7167
  # Longitude: 110.3500

  CACHE_FILE="$HOME/.cache/prayer_times.json"
  CACHE_MAX_AGE=43200  # 12 jam dalam detik

  # Fungsi untuk mendapatkan data waktu sholat
  get_prayer_times() {
      # Koordinat untuk Kabupaten Sleman
      latitude="-7.7167"
      longitude="110.3500"

      # Parameter untuk API
      method=11  # Method 11 - Kementerian Agama RI, Indonesia

      # Mendapatkan tanggal hari ini
      current_date=$(date +"%d-%m-%Y")

      # Mengambil data dari API aladhan.com
      curl -s "http://api.aladhan.com/v1/timings/$current_date?latitude=$latitude&longitude=$longitude&method=$method" > "$CACHE_FILE"
  }

  # Cek apakah file cache sudah ada dan belum kadaluarsa
  if [ -f "$CACHE_FILE" ]; then
      # Cek umur file cache
      file_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
      if [ "$file_age" -gt "$CACHE_MAX_AGE" ]; then
          get_prayer_times
      fi
  else
      # Buat cache file jika belum ada
      mkdir -p "$(dirname "$CACHE_FILE")"
      get_prayer_times
  fi

  # Mengambil waktu sholat dari cache
  fajr=$(jq -r '.data.timings.Fajr' "$CACHE_FILE")
  sunrise=$(jq -r '.data.timings.Sunrise' "$CACHE_FILE")
  dhuhr=$(jq -r '.data.timings.Dhuhr' "$CACHE_FILE")
  asr=$(jq -r '.data.timings.Asr' "$CACHE_FILE")
  maghrib=$(jq -r '.data.timings.Maghrib' "$CACHE_FILE")
  isha=$(jq -r '.data.timings.Isha' "$CACHE_FILE")

  # Mendapatkan waktu sekarang untuk menentukan waktu sholat berikutnya
  current_time=$(date +%H:%M)

  # Konversi waktu ke format menit untuk perbandingan
  convert_to_minutes() {
      hour=$(echo "$1" | cut -d: -f1)
      minute=$(echo "$1" | cut -d: -f2)
      echo $((hour * 60 + minute))
  }

  current_minutes=$(convert_to_minutes "$current_time")
  fajr_minutes=$(convert_to_minutes "$fajr")
  sunrise_minutes=$(convert_to_minutes "$sunrise")
  dhuhr_minutes=$(convert_to_minutes "$dhuhr")
  asr_minutes=$(convert_to_minutes "$asr")
  maghrib_minutes=$(convert_to_minutes "$maghrib")
  isha_minutes=$(convert_to_minutes "$isha")

  # Menentukan waktu sholat berikutnya
  next_prayer=""
  next_time=""

  if [ "$current_minutes" -lt "$fajr_minutes" ]; then
      next_prayer="Subuh"
      next_time="$fajr"
  elif [ "$current_minutes" -lt "$dhuhr_minutes" ]; then
      next_prayer="Dzuhur"
      next_time="$dhuhr"
  elif [ "$current_minutes" -lt "$asr_minutes" ]; then
      next_prayer="Ashar"
      next_time="$asr"
  elif [ "$current_minutes" -lt "$maghrib_minutes" ]; then
      next_prayer="Maghrib"
      next_time="$maghrib"
  elif [ "$current_minutes" -lt "$isha_minutes" ]; then
      next_prayer="Isya"
      next_time="$isha"
  else
      next_prayer="Subuh"
      next_time="$fajr"
  fi

  # Output untuk waybar
  echo "{\"text\": \"$next_prayer $next_time\", \"tooltip\": \"Subuh: $fajr\\nTerbit: $sunrise\\nDzuhur: $dhuhr\\nAshar: $asr\\nMaghrib: $maghrib\\nIsya: $isha\"}"

  exit 0
''

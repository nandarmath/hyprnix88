# Script untuk menampilkan waktu sholat berdasarkan lokasi dinamis (IP)
# Memanfaatkan API untuk geolocasi dan API aladhan.com untuk waktu sholat
# Script ini juga akan menjalankan reminder.sh untuk notifikasi waktu sholat
{pkgs}:
pkgs.writeShellScriptBin "prayer_time" ''

  CACHE_DIR="$HOME/.cache/prayer_times"
  CACHE_FILE="$CACHE_DIR/prayer_times.json"
  LOCATION_CACHE="$CACHE_DIR/location.json"
  CACHE_MAX_AGE=43200  # 12 jam dalam detik

  # Membuat direktori cache jika belum ada
  mkdir -p "$CACHE_DIR"

  # Fungsi untuk mendapatkan lokasi berdasarkan IP
  get_location() {
      # Menggunakan ipinfo.io untuk mendapatkan lokasi berdasarkan IP
      curl -s "https://ipinfo.io" > "$LOCATION_CACHE"

      if [ $? -ne 0 ] || [ ! -s "$LOCATION_CACHE" ]; then
          # Fallback ke Sleman jika gagal
          echo '{
              "loc": "-7.7167,110.3500",
              "city": "Sleman",
              "region": "Yogyakarta"
          }' > "$LOCATION_CACHE"
      fi
  }

  # Fungsi untuk mendapatkan data waktu sholat
  get_prayer_times() {
      # Mengambil latitude dan longitude dari cache lokasi
      local loc=$(jq -r '.loc' "$LOCATION_CACHE")
      local latitude=$(echo "$loc" | cut -d, -f1)
      local longitude=$(echo "$loc" | cut -d, -f2)

      # Parameter untuk API
      method=11  # Method 11 - Kementerian Agama RI, Indonesia

      # Mendapatkan tanggal hari ini
      current_date=$(date +"%d-%m-%Y")

      # Mengambil data dari API aladhan.com
      curl -s "http://api.aladhan.com/v1/timings/$current_date?latitude=$latitude&longitude=$longitude&method=$method" > "$CACHE_FILE"

      # Menambahkan informasi lokasi ke file cache
      city=$(jq -r '.city' "$LOCATION_CACHE")
      region=$(jq -r '.region' "$LOCATION_CACHE")
      location_name="$city, $region"

      # Membuat file sementara
      temp_file=$(mktemp)

      # Menambahkan lokasi ke JSON
      jq --arg loc "$location_name" '. + {"location": $loc}' "$CACHE_FILE" > "$temp_file"
      mv "$temp_file" "$CACHE_FILE"
  }

  # Cek apakah file cache lokasi sudah ada dan belum kadaluarsa
  if [ -f "$LOCATION_CACHE" ]; then
      # Cek umur file cache
      file_age=$(($(date +%s) - $(stat -c %Y "$LOCATION_CACHE")))
      if [ "$file_age" -gt "$CACHE_MAX_AGE" ]; then
          get_location
      fi
  else
      # Buat cache lokasi jika belum ada
      get_location
  fi

  # Cek apakah file cache waktu sholat sudah ada dan belum kadaluarsa
  if [ -f "$CACHE_FILE" ]; then
      # Cek umur file cache
      file_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
      if [ "$file_age" -gt "$CACHE_MAX_AGE" ]; then
          get_prayer_times
      fi
  else
      # Buat cache file jika belum ada
      get_prayer_times
  fi

  # Mengambil waktu sholat dari cache
  fajr=$(jq -r '.data.timings.Fajr' "$CACHE_FILE")
  sunrise=$(jq -r '.data.timings.Sunrise' "$CACHE_FILE")
  dhuhr=$(jq -r '.data.timings.Dhuhr' "$CACHE_FILE")
  asr=$(jq -r '.data.timings.Asr' "$CACHE_FILE")
  maghrib=$(jq -r '.data.timings.Maghrib' "$CACHE_FILE")
  isha=$(jq -r '.data.timings.Isha' "$CACHE_FILE")
  location=$(jq -r '.location // "Lokasi tidak diketahui"' "$CACHE_FILE")

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
  echo "{\"text\": \"$next_prayer $next_time\", \"tooltip\": \"$location\\n\\nSubuh: $fajr\\nTerbit: $sunrise\\nDzuhur: $dhuhr\\nAshar: $asr\\nMaghrib: $maghrib\\nIsya: $isha\", \"location\": \"$location\"}"

  # Jalankan reminder untuk memeriksa apakah waktu sholat telah tiba
  prayer_reminder &

  exit 0
''

{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "droidcam-rofi" ''
  #!${pkgs.bash}/bin/bash

  # Script untuk menjalankan DroidCam dengan berbagai opsi melalui Rofi

  # Array untuk opsi yang tersedia
  options=(
      "Audio Only "
      "Video & Audio "
      "Video Only "
  )

  # Meminta pengguna memilih opsi menggunakan Rofi
  selected_option=$(printf "%s\n" "''${options[@]}" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "Pilih Mode DroidCam:")

  # Keluar jika tidak ada yang dipilih
  if [ -z "$selected_option" ]; then
      exit 0
  fi

  # Meminta IP dan Port menggunakan Rofi (default: 192.168.1.9 4747)
  ip_port=$(echo " " | ${pkgs.rofi}/bin/rofi -dmenu -p "IP dan Port (default: 192.168.43.1 4747):")

  # Keluar jika tidak ada yang dimasukkan
  if [ -z "$ip_port" ]; then
      exit 0
  fi

  # Pisahkan IP dan Port
  ip=$(echo "$ip_port" | ${pkgs.gawk}/bin/awk '{print $1}')
  port=$(echo "$ip_port" | ${pkgs.gawk}/bin/awk '{print $2}')

  # Default port jika tidak dimasukkan
  if [ -z "$port" ]; then
      port="4747"
  fi

  # Path ke droidcam-cli
  DROIDCAM_CLI="${pkgs.droidcam}/bin/droidcam-cli"

  # Eksekusi perintah berdasarkan opsi yang dipilih
  case "$selected_option" in
      "Audio Only "
          cmd="$DROIDCAM_CLI -a $ip $port &"
          mode="Audio Only"
          ;;
      "Video & Audio "
          cmd="$DROIDCAM_CLI -a -v $ip $port &"
          mode="Video & Audio"
          ;;
      "Video Only "
          cmd="$DROIDCAM_CLI $ip $port &"
          mode="Video Only"
          ;;
      *)
          exit 1
          ;;
  esac

  # Jalankan perintah
  echo "Menjalankan: $cmd"
  eval "$cmd"

  # Tampilkan notifikasi
  ${pkgs.libnotify}/bin/notify-send "DroidCam" "Memulai DroidCam dengan mode: $mode"
''

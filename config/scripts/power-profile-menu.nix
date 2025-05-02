{ pkgs ? import <nixpkgs> {}, 
}:
pkgs.writeScriptBin "power-profile-menu" ''
      #!/usr/bin/env bash
      # Dapatkan profil saat ini
      current_profile=$(powerprofilesctl get)

      # Tampilkan menu rofi
      chosen=$(printf "power-saver\nbalanced\nperformance" | rofi -dmenu -i -p "Power Profile (Current: $current_profile)")

      # Terapkan profil yang dipilih
      if [ -n "$chosen" ]; then
          # Jalankan power-profiles-daemon dengan prioritas tinggi
          powerprofilesctl set $chosen
          
          # Beri notifikasi
          notify-send "Power Profile" "Switched to $chosen mode (overriding TLP)"
          
          # Opsional: Nonaktifkan TLP sementara untuk menghindari konflik
          if [ "$chosen" != "$current_profile" ]; then
              sudo systemctl stop tlp.service
              sleep 1
              sudo systemctl start tlp.service
          fi
      fi




    ''

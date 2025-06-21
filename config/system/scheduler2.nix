{
  config,
  lib,
  pkgs,
  ...
}: {
  # default scheduler
  services.scx.enable = true;
  services.scx.package = lib.mkDefault pkgs.scx.full;
  services.scx.scheduler = "scx_bpfland";
  services.scx.extraArgs = ["-f" "-k" "-p"];

  # change scheduler to scx_flash when power is on
  systemd.services.scx.serviceConfig = with config.services.scx; let
    alter = "${lib.getExe' package "scx_rusty"} -k";
    default = lib.concatStringsSep " " ([(lib.getExe' package scheduler)] ++ extraArgs);
  in {
    ExecStart = lib.mkForce (pkgs.writeScript "scx.sh"
    /*
    bash
    */
    ''
      #!${lib.getExe pkgs.bash}
      
      # Fungsi untuk mencari file status baterai
      find_battery_status() {
        # Cari semua direktori power_supply yang mungkin berisi status baterai
        for bat in /sys/class/power_supply/*/; do
          # Periksa apakah ini adalah baterai (bukan AC adapter)
          if [ -f "$bat/type" ] && [ "$(cat "$bat/type" 2>/dev/null)" = "Battery" ]; then
            # Periksa apakah file status ada
            if [ -f "$bat/status" ]; then
              echo "$(cat "$bat/status" 2>/dev/null)"
              return 0
            fi
          fi
        done
        
        # Fallback ke BAT0 jika pencarian gagal
        if [ -f "/sys/class/power_supply/BAT0/status" ]; then
          echo "$(cat "/sys/class/power_supply/BAT0/status" 2>/dev/null)"
          return 0
        fi
        
        # Jika tidak menemukan status, kembalikan status default "Unknown"
        echo "Unknown"
        return 1
      }

      # Dapatkan status baterai
      BATTERY_STATUS=$(find_battery_status)
      
      # Log status baterai untuk debugging
      echo "Battery status: $BATTERY_STATUS" > /tmp/scx_battery_status.log
      
      # Tentukan scheduler berdasarkan status baterai
      if [ "$BATTERY_STATUS" = "Discharging" ]; then
        echo "Running with default scheduler: ${default}" >> /tmp/scx_battery_status.log
        exec ${default}
      else
        # Kondisi Charging atau Not Charging atau Unknown
        echo "Running with alter scheduler: ${alter}" >> /tmp/scx_battery_status.log
        exec ${alter}
      fi
    '');
  };

  systemd.services."scx-refresh" = {
    unitConfig = {
      Description = "refresh scx";
    };
    script = ''
      # Log timestamp untuk debugging
      echo "SCX refresh triggered at $(date)" > /tmp/scx_refresh.log
      
      if systemctl status scx.service &>/dev/null; then
        echo "Stopping SCX service" >> /tmp/scx_refresh.log
        systemctl stop scx.service
      fi
      
      echo "Starting SCX service" >> /tmp/scx_refresh.log
      systemctl start scx.service
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Perbaikan udev rules untuk menangani semua status
  services.udev.extraRules =
  /*
  udev
  */
  ''
    # Monitor perubahan status power supply
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Discharging", ENV{SYSTEMD_WANTS}="scx-refresh.service"
  '';

  # Tambahkan tmpfiles rule untuk memastikan log dapat dibuat
  systemd.tmpfiles.rules = [
    "f /tmp/scx_battery_status.log 0644 root root - -"
    "f /tmp/scx_refresh.log 0644 root root - -"
  ];
}

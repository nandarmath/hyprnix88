{ config, pkgs, ... }:

{
  # Script untuk koordinasi TLP dan power-profiles-daemon
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "power-profile-sync" ''
      #!/usr/bin/env bash
      
      # Simpan status p-p-d saat ini
      PPD_PROFILE=$(powerprofilesctl get)
      
      # Jalankan TLP manual, tapi pertahankan pengaturan p-p-d
      sudo tlp start
      
      # Kembalikan profil p-p-d jika tidak default
      if [ "$PPD_PROFILE" != "balanced" ]; then
          powerprofilesctl set $PPD_PROFILE
      fi
      
      notify-send "Power Management" "Synced TLP and power-profiles-daemon"
    '')
  ];

  # Jalankan script saat login
  systemd.user.services.power-profile-sync = {
    description = "Sync TLP and power-profiles-daemon settings";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScript "power-profile-sync-exec" ''
        #!/bin/sh
        sleep 30  # Tunggu hingga desktop siap
        ${pkgs.bash}/bin/bash ${pkgs.power-profile-sync}/bin/power-profile-sync
      ''}";
    };
  };
}

{config, lib, pkgs, ... }:{

# default scheduler
  services.scx.enable = true;
  services.scx.scheduler = "scx_bpfland";
  services.scx.extraArgs = [ "-k" "-p" ];

  # change scheduler to scx_flash when power is on
  systemd.services.scx.serviceConfig = with config.services.scx; let
    alter = "${lib.getExe' package "scx_flash"} -k";
    default = lib.concatStringsSep " " ([ (lib.getExe' package scheduler) ] ++ extraArgs);
  in {
    ExecStart = lib.mkForce (pkgs.writeScript "scx.sh" /* bash */ ''
      #!${lib.getExe pkgs.bash}
      
      # if discarging, use default, if else use alter
      if [[ "$(cat /sys/class/power_supply/BAT0/status)" == "Discharging" ]]; then
        exec ${default}
      else
        exec ${alter}
      fi
    '');
  };

  systemd.services."scx-refresh" = {
    unitConfig = {
      Description = "refresh scx";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "scx-refresh.sh" ''
        #!${lib.getExe pkgs.bash}

        if systemctl status scx.service &>/dev/null; then
          systemctl stop scx.service
        fi
        systemctl start scx.service
      '';
    };
  };

  services.udev.extraRules = /* udev */ ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Charging", ENV{SYSTEMD_WANTS}="scx-refresh.service"
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Discharging", ENV{SYSTEMD_WANTS}="scx-refresh.service"
  '';
}


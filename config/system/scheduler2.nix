{ config, lib, pkgs, ... }:

{
  # Default scheduler setup
  services.scx = {
    enable = true;
    scheduler = "scx_bpfland";
    extraArgs = ["-f" "-k" "-p"];
  };

  # Modify scheduler service based on power status
  systemd.services.scx.serviceConfig = with config.services.scx; let
    alter = "${lib.getExe' package "scx_flash"} -k";
    default = lib.concatMapStringsSep " " (x: "${x}") 
              ([ (lib.getExe' package scheduler) ] ++ extraArgs);
  in {
    ExecStart = lib.mkForce (pkgs.writeShellScript "scx.sh" ''
      # Check if battery exists first
      if [ -e /sys/class/power_supply/BAT0 ]; then
        # If discharging, use default scheduler (scx_bpfland)
        if [[ "$(cat /sys/class/power_supply/BAT0/status)" == "Discharging" ]]; then
          echo "Running with default scheduler: ${default}"
          exec ${default}
        else
          echo "Running with alternate scheduler: ${alter}"
          exec ${alter}
        fi
      else
        # Fallback if no battery is detected
        echo "No battery detected, using default scheduler"
        exec ${default}
      fi
    '');
    Restart = "on-failure";
    RestartSec = "5s";
  };

  # Service to refresh the SCX scheduler when power status changes
  systemd.services."scx-refresh" = {
    description = "Refresh SCX scheduler based on power status";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "scx-refresh.sh" ''
        echo "Refreshing SCX scheduler service..."
        systemctl try-restart scx.service
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };

  # udev rules to trigger service when power status changes
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{status}=="Charging", RUN+="${pkgs.systemd}/bin/systemctl start scx-refresh.service"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="${pkgs.systemd}/bin/systemctl start scx-refresh.service"
    SUBSYSTEM=="power_supply", ATTR{status}=="Not charging", RUN+="${pkgs.systemd}/bin/systemctl start scx-refresh.service"
    SUBSYSTEM=="power_supply", ATTR{status}=="Full", RUN+="${pkgs.systemd}/bin/systemctl start scx-refresh.service"
  '';
}

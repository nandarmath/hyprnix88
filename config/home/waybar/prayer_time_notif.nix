{
  config,
  pkgs,
  ...
}: {
  # Konfigurasi lain yang sudah ada...

  systemd.user.services.prayer-reminder = {
    description = "Prayer Time Notification Service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.prayer_time}/bin/prayer_time";
      Environment = [
        "DISPLAY=:0"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
      ];
    };
  };

  systemd.user.timers.prayer-reminder = {
    description = "Run prayer time notifications every minute";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "prayer-reminder.service";
    };
  };
}

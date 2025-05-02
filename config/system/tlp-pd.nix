{ config, pkgs, ... }:

{
  # Konfigurasi TLP sebagai pengatur daya default
  services.tlp = {
    enable = true;
    settings = {
      # Threshold baterai
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
      
      # Pengaturan kinerja default
      CPU_SCALING_GOVERNOR_ON_AC = "balanced";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # Penting: Izinkan override dari power-profiles-daemon
      RESTORE_DEVICE_STATE_ON_STARTUP = 0;
    };
  };

  # Aktifkan power-profiles-daemon tetapi dengan prioritas lebih tinggi
  services.power-profiles-daemon = {
    enable = true;
  };

  # Atur agar power-profiles-daemon dijalankan setelah TLP
  # dan dapat mengambil alih pengaturan dari TLP saat digunakan
  systemd.services.power-profiles-daemon = {
    after = [ "tlp.service" ];
    conflicts = [];  # Hapus konflik default
  };

  # Tambahkan script hook untuk TLP
  environment.etc."tlp.d/01-allow-ppd-override.conf".text = ''
    # Izinkan override dari power-profiles-daemon
    TLP_DEFAULT_MODE=AC
    TLP_PERSISTENT_DEFAULT=0
  '';

  # Pastikan polkit diatur dengan benar
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.hadess.PowerProfiles.switchProfile" &&
          subject.isInGroup("users")) {
          return polkit.Result.YES;
      }
    });
  '';
}

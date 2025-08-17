{
  pkgs,
  config,
  lib,
  ...
}:

{
  # List services that you want to enable:
  services.openssh.enable = true;
  services.fstrim.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [
  #     # pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal
  #   ];
  #   configPackages = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-hyprland
  #     pkgs.xdg-desktop-portal
  #   ];
  # };
  programs.noisetorch.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber = {
      enable = true;
      package = pkgs.wireplumber;

    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [
    49152
    53317
    5900
    8181
    8787
    7236
    7250
    443
    53
    11434
    3000
    6600
    6800
    9980
  ];
  networking.firewall.allowedTCPPorts = [
    80
    85
    443
    5900
    53317
    8181
    7236
    5353
    8787
    22
    53
    11434
    3000
    6600
    6800
    9980
    51820
  ];
  services.pulseaudio.enable = false;
  # sound.enable = true;
  security.rtkit.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
    fprintAuth = true;
  };
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "100000";
    }
  ];
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };
  services.smartd = {
    enable = true;
    autodetect = true;
  };
  services.preload = {
    enable = false;
    package = pkgs.preload;
  };
  services.gnome.gnome-keyring.enable = true;
  # For thinkpad
  #services.tlp ={
  #  enable = true;
  #  settings = {
  #    START_CHARGE_THRESH_BAT0=75;
  #    STOP_CHARGE_THRESH_BAT0=90;

  #  };
  #};
  # Battery power management
  #services.upower.enable = false;

  # Enable thermald for CPU temperature auto handling.
  services.thermald.enable = true;
  virtualisation.waydroid.enable = true;
  # Enable throttled.service for fix Intel CPU throttling.
  services.throttled.enable = true;

}

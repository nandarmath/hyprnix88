{ pkgs, config, lib, ... }:

{
  # List services that you want to enable:
  services.openssh.enable = true;
  services.fstrim.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [ pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
  };
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [49152 53317 443];
  networking.firewall.allowedTCPPorts = [80 443 53317 22];
  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce;[
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
  };
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
  };

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
  


  # Enable NGINX
 #services.nginx = {
 #  enable = true;
 #  virtualHosts."localhost" = {
 #      root = "/home/vmandela/code/gh-blog/_site";
 #  };
 #};
}

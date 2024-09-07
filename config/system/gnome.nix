{pkgs, config, lib, ...}:
{
services.xserver.desktopManager.gnome.enable = true;
 environment.gnome.excludePackages = (with pkgs; [
    # for packages that are pkgs.*
    gnome-tour
    gnome-connections

  ]) ++ (with pkgs.gnome; [
    # for packages that are pkgs.gnome.*
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-tweaks
    gnome-shell-extensions
  ]) ++ (with pkgs;[
    whitesur-gtk-theme
    whitesur-cursors
    whitesur-icon-theme
  ]);

environment.systemPackages = with pkgs.gnomeExtensions; [
    blur-my-shell
    pop-shell
    dash-to-dock
    copier
    weather
    thinkpad-battery-threshold
    thinkpad-thermal
    logo-menu
    tophat
    clipqr
    next-up
    open-bar
    color-picker
    panel-corners
    astra-monitor
    compiz-alike-magic-lamp-effect

    # ...
  ];
  services.xserver.desktopManager.gnome = { 
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      tap-to-click=true
    '';
    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # for org.gnome.desktop
      pkgs.gnome.gnome-shell # for org.gnome.shell
    ];
  };



}

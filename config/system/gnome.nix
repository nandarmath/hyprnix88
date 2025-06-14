{pkgs, gnomeSchema, config, lib, ...}:
let 
gnomeShellSchema = "${gnomeSchema}/shell";
extensionSchema = "${gnomeShellSchema}/extensions";
in
{
services.desktopManager.gnome.enable = true;
 environment.gnome.excludePackages = (with pkgs; [
    # for packages that are pkgs.*
    gnome-tour
    gnome-connections

  ]) ++ (with pkgs; [
    # for packages that are pkgs.gnome.*
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-tweaks
    gnome-shell-extensions
    dconf-editor
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
    # thinkpad-battery-threshold
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
  services.desktopManager.gnome = { 
    extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      tap-to-click=true
    '';
    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # for org.gnome.desktop
      pkgs.gnome-shell # for org.gnome.shell
    ];
  };

  # dconf.settings ={
  #   "${extensionSchema}/draw-on-your-screen" ={
  #     persistent
  #   };
  # };

}

{ pkgs, config, inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List System Programs
  environment.systemPackages = with pkgs; [
    wget curl git cmatrix lolcat neofetch htop btop libvirt
    polkit_gnome wineWowPackages.wayland ntfs3g lm_sensors unzip unrar libnotify eza pipewire wireplumber qt6.qtwayland qt5.qtwayland
    v4l-utils ydotool wl-clipboard socat cowsay lsd lshw stow
    pkg-config meson protonvpn-cli hugo gnumake ninja go nodejs symbola
    noto-fonts-color-emoji material-icons brightnessctl
    toybox virt-viewer swappy ripgrep appimage-run pdftk poppler_utils
    networkmanagerapplet yad bluez pulseaudio wayland-utils xdg-utils
  ];

  programs.steam.gamescopeSession.enable = true;
  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.setPath.enable = true;
  };
  
  programs.fuse.userAllowOther = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}

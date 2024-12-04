{ pkgs, config, inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List System Programs
  environment.systemPackages = with pkgs; [
    wget gcc curl git cmatrix lolcat neofetch htop btop libvirt
    polkit_gnome wineWowPackages.wayland ntfs3g lm_sensors unzip unrar libnotify eza pipewire wireplumber qt6.qtwayland qt5.qtwayland
    v4l-utils ydotool nh
    rofi-systemd
    (rofi.override {
      plugins = [rofi-file-browser rofi-calc];
    })
    r2411.quarto
    r2411.jasp-desktop
    imagemagick
    distrobox
    nix-output-monitor
    kdePackages.qt6ct
    wl-clipboard socat cowsay lsd lshw stow
    pkg-config meson cloudflared protonvpn-cli hugo lazygit ripgrep bottom neovim gnumake ninja go nodejs symbola
    noto-fonts-color-emoji material-icons brightnessctl
    toybox virt-viewer swappy ripgrep appimage-run pdftk poppler_utils
    networkmanagerapplet yad bluez pulseaudio wayland-utils xdg-utils
    # whitesur-gtk-theme
    # whitesur-cursors
    # whitesur-icon-theme
    gnome-tweaks
    gnome-shell-extensions
    # whatsapp-for-linux
    stirling-pdf
    nil
    typst
    typstyle
    typst-lsp
    typstfmt
    typst-live
    vscodium
    tinymist
    vscode-extensions.myriad-dreamin.tinymist
    # inputs.nvix.packages.${system}.full
    r2405.zoom-us
    # hyprpanel
    # scratch-desktop
    cachix
    nixpkgs-fmt
    nushell
    hyprnome
    openrefine
    teams-for-linux
    pkgs.fmpkgs.xdman
    calcure
    preload
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

{
  pkgs,
  config,
  inputs,
  ...
}:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List System Programs
  environment.systemPackages = with pkgs; [
    wget
    cmake
    gcc
    curl
    git
    cmatrix
    lolcat
    htop
    btop
    polkit_gnome
    winetricks
    wineWowPackages.waylandFull
    ntfs3g
    lm_sensors
    unzip
    unrar
    libnotify
    eza
    pipewire
    wireplumber
    qt6.qtwayland
    qt5.qtwayland
    v4l-utils
    nh
    dateutils
    gtk3
    gtk-layer-shell
    rofi-systemd
    quarto
    inxi
    jasp-desktop
    imagemagick
    distrobox
    nix-output-monitor
    kdePackages.qt6ct
    socat
    cowsay
    lsd
    lshw
    stow
    pkg-config
    meson
    cloudflared
    # protonvpn-cli
    lazygit
    ripgrep
    bottom
    neovim
    gnumake
    ninja
    go
    nodejs
    symbola
    noto-fonts-color-emoji
    material-icons
    brightnessctl
    toybox
    appimage-run
    pdftk
    poppler_utils
    networkmanagerapplet
    yad
    bluez
    pulseaudio
    wayland-utils
    xdg-utils
    fprintd
    wofi
    gnome-tweaks
    gnome-shell-extensions
    # whatsapp-for-linux
    stirling-pdf
    nil
    typst
    typstyle
    # typst-lsp
    typstfmt
    typst-live
    vscodium
    tinymist
    vscode-extensions.myriad-dreamin.tinymist
    # inputs.nvix.packages.${system}.full
    r2405.zoom-us
    r2205.hugo
    # rnew.positron-bin
    python312Packages.pymonctl
    rofi-network-manager
    python312Packages.pywinctl

    # zoom-us
    # hyprpanel
    # scratch-desktop
    cachix
    nixpkgs-fmt
    nushell
    hyprnome
    openrefine
    teams-for-linux
    # pkgs.fmpkgs.xdman
    calcure
    preload
    nix-prefetch-github
    nix-init
    fzf
    rustdesk-flutter

    wvkbd
    iio-hyprland
    iio-sensor-proxy
    # gnome-network-displays
    miraclecast
    mkcert
    # lmstudio
    ollama
    open-webui
    # ferdium
    # keepassxc
    newsflash
    inputs.zen-browser.packages."${system}".specific
    vim
    gimp3
    gimp3-with-plugins
    libwacom
    base16-schemes
    # uwsm
  ];

  programs.steam.gamescopeSession.enable = true;
  programs.dconf.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    withUWSM = false;
    # xwayland.enable = true;
    # systemd.setPath.enable = true;
  };

  # For Autorotate on tablet mode with x390 yoga
  programs.iio-hyprland = {
    enable = true;
    package = pkgs.iio-hyprland;
  };
  hardware.sensor.iio.enable = true;
  programs.fuse.userAllowOther = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

}

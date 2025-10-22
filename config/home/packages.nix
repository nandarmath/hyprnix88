{pkgs, ...}: let
  inherit
    (import ../../options.nix)
    browser
    ;
in {
  # Install Packages For The User
  home.packages = with pkgs; [
    pkgs."${browser}"
    # discord
    libvirt
    tty-clock
    kalker
    file-roller
    ffmpeg
    wf-recorder
    wl-screenrec
    noisetorch
    wayvnc
    tree
    zoxide
    android-tools
    swaynotificationcenter
    nwg-dock-hyprland
    pyprland
    pandoc
    pistol
    imv
    transmission_3-gtk
    mpv
    gitg
    vlc
    xournalpp
    # positron-bin
    # openboard
    blender
    gabutdm
    # pairdrop
    rustup
    nix-search-cli
    ghostscript
    gparted
    droidcam
    thinkpad-scripts
    cpu-x
    tenacity
    pavucontrol
    rofi-bluetooth
    pdfarranger
    chromium
    floorp-unwrapped
    brave
    tgpt
    bat
    scrcpy
    mpd
    nodejs_22
    jq
    bc
    drawio
    sticky
    rclone
    rclone-browser
    krita
    sweethome3d.application
    sweethome3d.furniture-editor
    libreoffice-qt-fresh
    # thunderbird-bin
    localsend
    converseen
    satty
    glab
    calibre
    jdk
    inkscape-with-extensions
    # gimp-with-plugins
    ytfzf
    kitty
    ueberzugpp
    gImageReader
    tesseract
    hunspell
    hunspellDicts.id_ID
    hunspellDicts.en_US
    tdesktop
    sigil
    rnote
    pfetch
    syncthing
    geogebra6
    yt-dlp
    # pspp
    kdePackages.okular
    scribus
    handbrake
    zotero
    spotify
    swayidle
    neovide
    swaylock
    hyprpicker
    cliphist
    joplin-desktop
    joplin
    aria2
    clipmenu
    xsel
    zed-editor
    # fmpkgs.xdman
    fastfetch
    xfce.exo
    ddgr
    appflowy
    ocrmypdf
    # fuzzel
    nixd
    nixfmt-rfc-style
    hyprshot
    wasistlos
    # hyprpanel
    varia ## download manager
    # planify # taks manager
    # parabolic # front-end yt-dlp / download video and audio
    loupe # image viewer support touchscreen
    # amberol # music and audio player
    vesktop # discord app client elternative
    netscanner # Network scanner & diagnostic tool.
    socat
    procps
    mutt-wizard
    pass
    thunderbird-bin
    libqalculate
    zenity
    sdcv
    translate-shell
    # google-chrome
    backgroundremover
    onlyoffice-desktopeditors
    # wpsoffice-cn
    dmenu
    htmlq
    didyoumean
    dig
    speedtest-cli
    keepmenu
    pinentry-gtk2
    walker


    # tvbrowser
    (pkgs.callPackage ../pkgs/amzqr.nix {})
    (pkgs.callPackage ../pkgs/ffmpegsplitpy.nix {})
    # (pkgs.callPackage ../pkgs/lumi.nix {})
    # Import Scripts
  ];

  programs.gh.enable = true;
}

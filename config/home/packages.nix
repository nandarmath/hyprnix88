{pkgs, username, ... }:

let
  inherit (import ../../options.nix)
    browser wallpaperDir wallpaperGit flakeDir;
in {
  # Install Packages For The User
  home.packages = with pkgs; [
    pkgs."${browser}" discord libvirt swww grim slurp file-roller ffmpeg wf-recorder wl-screenrec tree zoxide android-tools
    swaynotificationcenter nwg-dock-hyprland pyprland pandoc pistol rofi-power-menu imv transmission_3-gtk 
    mpv
    # smplayer
    rofi-pulse-select gitg vlc xournalpp
    # openboard
    blender
    persepolis
    gabutdm
    pairdrop
    rustup nix-search-cli microsoft-edge ghostscript gparted droidcam thinkpad-scripts cpu-x tenacity pavucontrol rofi-bluetooth pdfarranger chromium tgpt bat scrcpy mpd
    nodejs_22
    jq drawio sticky rclone rclone-browser krita sweethome3d.application sweethome3d.furniture-editor
    libreoffice-qt-fresh
    # thunderbird-bin
    # zed-editor
    localsend converseen satty onboard glab
    # calibre
    brave kalker jdk inkscape-with-extensions gimp-with-plugins ytfzf kitty ueberzugpp gImageReader tesseract hunspell hunspellDicts.id_ID hunspellDicts.en_US
    tdesktop sigil rnote pfetch libsForQt5.kget syncthing geogebra
    lunarvim
    yt-dlp pspp okular
    # anydesk
    teamviewer
    # goldendict-ng
    scribus handbrake zotero
    spotify swayidle neovide swaylock hyprpicker cliphist joplin-desktop joplin
    rofi-wayland aria2 clipmenu xsel lapce
    fmpkgs.xdman
    fastfetch
    xfce.exo
    ddgr
    appflowy
    wasistlos
    ocrmypdf
    rofi-mpd
    fuzzel
    nixd
    # tvbrowser
    (pkgs.callPackage ../pkgs/amzqr.nix {})
    (pkgs.callPackage ../pkgs/ffmpegsplitpy.nix {})
    # (pkgs.callPackage ../pkgs/lumi.nix {})
    # Import Scripts
    (import ./../scripts/emopicker9000.nix { inherit pkgs;})
    (import ./../scripts/task-waybar.nix { inherit pkgs; })
    (import ./../scripts/squirtle.nix { inherit pkgs; })
    # (import ./../scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir;
      # inherit username; inherit wallpaperGit; })
    (import ./../scripts/themechange.nix { inherit pkgs; inherit flakeDir; })
    (import ./../scripts/theme-selector.nix { inherit pkgs; })
    (import ./../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ./../scripts/web-search.nix { inherit pkgs; })
    (import ./../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./../scripts/screenshootin.nix { inherit pkgs; })
    (import ./../scripts/zcc.nix { inherit pkgs; })
    (import ./../scripts/dmenu-mager.nix { inherit pkgs; })
    (import ./../scripts/dmenu_iptv.nix { inherit pkgs; })
    (import ./../scripts/terjemah.nix { inherit pkgs; })
    (import ./../scripts/dmenu_ffmpeg.nix { inherit pkgs; })
    (import ./../scripts/pdf-extractor.nix { inherit pkgs; })
    # (import ./../scripts/transkripsi.nix { inherit pkgs; })
    (import ./../scripts/komprespdf.nix { inherit pkgs; })
    (import ./../scripts/rofi-finder.nix { inherit pkgs; })
    (import ./../scripts/qr-generator.nix { inherit pkgs; })
    # (import ./../scripts/pasopati.nix { inherit pkgs; })
    (import ./../scripts/dmenu_aria.nix { inherit pkgs; })
    # (import ./../scripts/rofi-calc.nix { inherit pkgs; })
    (import ./../scripts/translate.nix { inherit pkgs; })
    (import ./../scripts/window-selector.nix { inherit pkgs; })
    (import ./../scripts/dmenu_dns.nix { inherit pkgs; })
    (import ./../scripts/mp.nix { inherit pkgs; })
    (import ./../scripts/dmenu_translate.nix { inherit pkgs; })
    (import ./../scripts/list-hypr-bindings.nix { inherit pkgs; })
    (import ./../scripts/wofi/wofi-iptv.nix { inherit pkgs; })
    (import ./../scripts/wofi/wofi-mager.nix { inherit pkgs; })
    (import ./../scripts/ocr-indonesia.nix { inherit pkgs; })
    (import ./../scripts/ocr-screenshoot.nix { inherit pkgs; })
    (import ./../scripts/rofi-calc.nix { inherit pkgs; })
    (import ./../scripts/rofi-wf.nix { inherit pkgs; })
    (import ./../scripts/sattyss.nix { inherit pkgs; })
    # (import ./../scripts/pdfextrac.nix { inherit pkgs; })
    #(import ./../scripts/wvkbd.nix { inherit pkgs; })
  ];

  programs.gh.enable = true;
}

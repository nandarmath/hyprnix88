{ pkgs, config, username, ... }:

let 
  inherit (import ../../options.nix) 
    browser wallpaperDir wallpaperGit flakeDir;
in {
  # Install Packages For The User
  home.packages = with pkgs; [
    pkgs."${browser}" discord libvirt swww grim slurp gnome.file-roller ffmpeg wf-recorder tree zoxide android-tools
    swaynotificationcenter nwg-dock-hyprland pyprland pandoc pistol rofi-power-menu imv transmission-gtk mpv rofi-pulse-select rofi-mpd gitg joshuto vlc xournalpp openboard blender
    rustup nix-search-cli microsoft-edge wvkbd ghostscript gparted droidcam thinkpad-scripts cpu-x tenacity pavucontrol rofi-bluetooth pdfarranger chromium tgpt bat scrcpy mpd nodejs_22 jq drawio sticky rclone rclone-browser krita sweethome3d.application sweethome3d.furniture-editor
    libreoffice-qt-fresh zoom-us thunderbird-bin zed-editor localsend quarto jasp-desktop converseen satty onboard glab webcamoid calibre brave kalker onlyoffice-bin_latest jdk inkscape-with-extensions gimp-with-plugins ytfzf kitty ueberzugpp gImageReader tesseract hunspell hunspellDicts.en_US
    tdesktop sigil rnote pfetch libsForQt5.kget syncthing geogebra lunarvim yt-dlp pspp okular goldendict-ng scribus handbrake zotero joplin keepassxc
    spotify swayidle neovide element-desktop swaylock hyprpicker cliphist joplin-desktop
    rofi-wayland aria2 clipmenu xsel lapce
    #(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # Import Scripts
    (import ./../scripts/emopicker9000.nix { inherit pkgs;})
    (import ./../scripts/task-waybar.nix { inherit pkgs; })
    (import ./../scripts/squirtle.nix { inherit pkgs; })
    (import ./../scripts/wallsetter.nix { inherit pkgs; inherit wallpaperDir;
      inherit username; inherit wallpaperGit; })
    (import ./../scripts/themechange.nix { inherit pkgs; inherit flakeDir; })
    (import ./../scripts/theme-selector.nix { inherit pkgs; })
    (import ./../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ./../scripts/web-search.nix { inherit pkgs; })
    (import ./../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./../scripts/screenshootin.nix { inherit pkgs; })
    (import ./../scripts/zcc.nix { inherit pkgs; })
    (import ./../scripts/dmenu-mager.nix { inherit pkgs; })
    (import ./../scripts/dmenu_iptv.nix { inherit pkgs; })
    (import ./../scripts/dmenu_ffmpeg.nix { inherit pkgs; })
    # (import ./../scripts/pdf-extractor.nix { inherit pkgs; })
    # (import ./../scripts/pasopati.nix { inherit pkgs; })
    (import ./../scripts/dmenu_aria.nix { inherit pkgs; })
    # (import ./../scripts/rofi-calc.nix { inherit pkgs; })
    (import ./../scripts/translate.nix { inherit pkgs; })
    (import ./../scripts/window-selector.nix { inherit pkgs; })
    (import ./../scripts/dmenu_dns.nix { inherit pkgs; })
    (import ./../scripts/dmenu_translate.nix { inherit pkgs; })
    (import ./../scripts/joshuto-wrapper.nix { inherit pkgs; })
    (import ./../scripts/list-hypr-bindings.nix { inherit pkgs; })
    # (import ./../scripts/pdfextrac.nix { inherit pkgs; })
    #(import ./../scripts/wvkbd.nix { inherit pkgs; })
  ];

  programs.gh.enable = true;
}

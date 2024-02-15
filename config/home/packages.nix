{ pkgs, config, username, ... }:

let 
  inherit (import ../../options.nix) 
    browser wallpaperDir wallpaperGit flakeDir;
in {
  # Install Packages For The User
  home.packages = with pkgs; [
    pkgs."${browser}" discord libvirt swww grim slurp gnome.file-roller
    swaynotificationcenter rofi-wayland rofi-power-menu rofi-calc imv transmission-gtk mpv
    obs-studio rustup audacity pavucontrol rofi-bluetooth pdfarranger chromium tgpt
    libreoffice-qt inkscape-with-extensions gimp-with-plugins ytfzf kitty ueberzugpp gImageReader tesseract hunspell hunspellDicts.en_US
    tdesktop rustdesk syncthing lunarvim yt-dlp pspp okular goldendict-ng scribus handbrake 
    font-awesome spotify swayidle neovide element-desktop swaylock hyprpicker cliphist zotero geogebra
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # Import Scripts
    (import ./../scripts/emopicker9000.nix { inherit pkgs; })
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
  ];

  programs.gh.enable = true;
}

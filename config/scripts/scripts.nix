{ pkgs, ... }:
let
  #wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  #wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (builtins.readFile ./scripts/wallpaper-picker.sh);

  keybinds = pkgs.writeShellScriptBin "keybinds" (builtins.readFile ./keybinds.sh);
  rofibeats = pkgs.writeShellScriptBin "rofibeats" (builtins.readFile ./RofiBeats.sh);
  screenrecorder = pkgs.writeShellScriptBin "screenrecorder" (builtins.readFile ./screenrecorder);
  waybar-timer = pkgs.writeShellScriptBin "waybar-timer" (builtins.readFile ./waybar-timer);
  rofi-filemanager = pkgs.writeShellScriptBin "rofi-filemanager" (
    builtins.readFile ./rofi-filemanager.sh
  );
  rofi-wlstream = pkgs.writeShellScriptBin "rofi-wlstream" (builtins.readFile ./rofi-wlstrem.sh);
  rofi-dict = pkgs.writeShellScriptBin "rofi-dict" (builtins.readFile ./rofi-dict.sh);
  rofi_calc = pkgs.writeShellScriptBin "rofi_calc" (builtins.readFile ./rofi-calc.sh);
  rofi-wallpaper = pkgs.writeShellScriptBin "rofi-wallpaper" (
    builtins.readFile ./wallpaper-picker.sh
  );
  # book-search = pkgs.writeShellScriptBin "book-search" (builtins.readFile ./books-search.sh);
  portalhyprland = pkgs.writeShellScriptBin "portalhyprland" (builtins.readFile ./portalhyprland.sh);
  virtmon = pkgs.writeShellScriptBin "virtmon" (builtins.readFile ./virtmon.sh);

in
{
  home.packages = with pkgs; [
    # wall-change
    # wallpaper-picker
    keybinds
    rofibeats
    screenrecorder
    waybar-timer
    rofi-wlstream
    rofi-filemanager
    rofi-dict
    rofi_calc
    rofi-wallpaper
    portalhyprland
    virtmon
    (import ./emopicker9000.nix { inherit pkgs; })
    (import ./task-waybar.nix { inherit pkgs; })
    (import ./squirtle.nix { inherit pkgs; })
    (import ./nvidia-offload.nix { inherit pkgs; })
    (import ./web-search.nix { inherit pkgs; })
    (import ./rofi-launcher.nix { inherit pkgs; })
    (import ./screenshootin.nix { inherit pkgs; })
    (import ./zcc.nix { inherit pkgs; })
    (import ./dmenu-mager.nix { inherit pkgs; })
    (import ./dmenu_iptv.nix { inherit pkgs; })
    (import ./terjemah.nix { inherit pkgs; })
    (import ./pdf-extractor.nix { inherit pkgs; })
    (import ./komprespdf.nix { inherit pkgs; })
    (import ./qr-generator.nix { inherit pkgs; })
    (import ./dmenu_aria.nix { inherit pkgs; })
    (import ./translate.nix { inherit pkgs; })
    (import ./window-selector.nix { inherit pkgs; })
    (import ./dmenu_dns.nix { inherit pkgs; })
    (import ./mp.nix { inherit pkgs; })
    (import ./dmenu_translate.nix { inherit pkgs; })
    (import ./list-hypr-bindings.nix { inherit pkgs; })
    (import ./wofi/wofi-iptv.nix { inherit pkgs; })
    (import ./wofi/wofi-mager.nix { inherit pkgs; })
    (import ./ocr-indonesia.nix { inherit pkgs; })
    (import ./ocr-screenshoot.nix { inherit pkgs; })
    (import ./sattyss.nix { inherit pkgs; })
    (import ./wl-record.nix { inherit pkgs; })
    (import ./wl-recordNoA.nix { inherit pkgs; })
    (import ./mirrorhp.nix { inherit pkgs; })
    (import ./rofi-droid.nix { inherit pkgs; })
    (import ./rofi-shot.nix { inherit pkgs; })
    (import ./dmenu_mpc.nix { inherit pkgs; })
    (import ./rofi-notes.nix { inherit pkgs; })
    (import ./prayer_time.nix { inherit pkgs; })
    (import ./wallsetter.nix { inherit pkgs; })
    (import ./rofi-zotero.nix { inherit pkgs; })
    (import ./displaymon.nix { inherit pkgs; })
    (import ./hyprland-dock.nix { inherit pkgs; })

  ];

  # home.file.".config/waybar/scripts/waybar_timer" = {
  #           source = ./waybar_timer;
  #           executable = true;
  #       };

}

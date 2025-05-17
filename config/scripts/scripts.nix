{pkgs, ...}: let
  #wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  #wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (builtins.readFile ./scripts/wallpaper-picker.sh);
  
  keybinds = pkgs.writeShellScriptBin "keybinds" (builtins.readFile ./keybinds.sh);
  rofibeats = pkgs.writeShellScriptBin "rofibeats" (builtins.readFile ./RofiBeats.sh);
  screenrecorder = pkgs.writeShellScriptBin "screenrecorder" (builtins.readFile ./screenrecorder);
  waybar-timer = pkgs.writeShellScriptBin "waybar-timer" (builtins.readFile ./waybar-timer);
  
  
  
in {
  home.packages = with pkgs; [
   # wall-change
   # wallpaper-picker
    keybinds
    rofibeats
    screenrecorder
    waybar-timer
  ];

  # home.file.".config/waybar/scripts/waybar_timer" = {
  #           source = ./waybar_timer;
  #           executable = true;
  #       };

}

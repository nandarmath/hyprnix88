{pkgs, ...}: let
  #wall-change = pkgs.writeShellScriptBin "wall-change" (builtins.readFile ./scripts/wall-change.sh);
  #wallpaper-picker = pkgs.writeShellScriptBin "wallpaper-picker" (builtins.readFile ./scripts/wallpaper-picker.sh);
  
  keybinds = pkgs.writeShellScriptBin "keybinds" (builtins.readFile ./keybinds.sh);
  rofibeats = pkgs.writeShellScriptBin "rofibeats" (builtins.readFile ./RofiBeats.sh);
  

  
in {
  home.packages = with pkgs; [
   # wall-change
   # wallpaper-picker
    keybinds
    rofibeats
  ];
}

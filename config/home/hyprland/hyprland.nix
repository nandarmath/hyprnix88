{ 
pkgs,
...
}:
let 
inherit
(import ../../../options.nix)
stylixImage
;
in {
  
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = with pkgs.hyprlandPlugins;[
      hyprgrass
      hyprexpo
    ];
  };

  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };



}

{ 
pkgs,
...
}:{

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = with pkgs.hyprlandPlugins;[
      hyprgrass
      hyprexpo
    ];
  };



}

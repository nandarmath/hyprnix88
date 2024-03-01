{ pkgs, config, ... }:

{
  # Place Files Inside Home Directory
  home.file.".emoji".source = ./files/emoji;
  home.file.".base16-themes".source = ./files/base16-themes;
  home.file.".face".source = ./files/face.jpg; # For GDM
  home.file.".face.icon".source = ./files/face.jpg; # For SDDM
  home.file.".config/rofi/rofi.jpg".source = ./files/rofi.jpg;
  home.file.".config/starship.toml".source = ./files/starship.toml;
  home.file.".local/share/fonts" = {
    source = ./files/fonts;
    recursive = true;
  };
 #home.file.".config/obs-studio" = {
 #  source = ./files/obs-studio;
 #  recursive = true;
 #};
  home.file.".config/pulse/default.pa".source = ./files/default.pa;
  home.file.".config/joshuto/icons.toml".source = ./files/joshuto/icons.toml;
  home.file.".config/joshuto/joshuto.toml".source = ./files/joshuto/joshuto.toml;
  home.file.".config/joshuto/keymap.toml".source = ./files/joshuto/keymap.toml;
  home.file.".config/joshuto/mimetype.toml".source = ./files/joshuto/mimetype.toml;
  home.file.".config/joshuto/theme.toml".source = ./files/joshuto/theme.toml;
  home.file.".config/joshuto/on_preview_removed" ={
    source = ./files/joshuto/on_preview_removed;
    executable = true;
  };
  home.file.".config/joshuto/on_preview_shown" ={
    source = ./files/joshuto/on_preview_shown;
    executable = true;
  };
  home.file.".config/joshuto/preview_file" ={
    source = ./files/joshuto/preview_file.sh;
    executable = true;
  };
  home.file.".config/hypr/pyprland.toml".source = ./files/pyprland.toml;

}

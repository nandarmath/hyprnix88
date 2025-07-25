{ pkgs,lib, config, gtkThemeFromScheme, ... }:

{
  # Configure Cursor Theme
  # home.pointerCursor = {
  #   gtk.enable = true;
  #   x11.enable = true;
  #   # package = pkgs.bibata-cursors;
  #   # name = "Bibata-Modern-Ice";
  #   # size = 24;
  # };

  # Theme GTK
  gtk = {
    # enable = true;
    # font = {
    #   name = "Ubuntu";
    #   size = 12;
    #   package = pkgs.ubuntu_font_family;
    # };
    # theme = {
    #   name = "${config.colorScheme.slug}";
    #   package = gtkThemeFromScheme {scheme = config.colorScheme;};
    # };
    iconTheme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
  };

  # Theme QT -> GTK
  qt = {
    enable = true;
    #platformTheme = "gtk";
    platformTheme.name = lib.mkForce "qtct";
    # style = {
    #     name = "adwaita-dark";
    #     package = pkgs.adwaita-qt;
    # };
  };
}

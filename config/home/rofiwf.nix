{
  pkgs,
  config,
  ...
}:
let
  palette = config.lib.stylix.colors;
in
{
  programs.rofi = {
    enable = true;
    font = "JetBrains Nerd Font 16";
    package = pkgs.rofi-wayland;
    plugins = [
      pkgs.rofi-file-browser
      pkgs.rofi-pass-wayland
      pkgs.rofi-pulse-select
      pkgs.rofi-systemd

    ];
    pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland;
      stores = [ "home/nandar/.pass" ];
    };
    extraConfig = {
      case-sensitive = false;
      display-drun = "❄️Apps ";
      display-run = " Run ";
      display-filebrowser = " Files ";
      display-window = " Windows ";
      display-recursivebrowser = "󱞊 MoreFiles ";
      modi = [
        "drun"
        "run"
        "filebrowser"
        "window"
        "recursivebrowser"
      ];
      show-icons = true;
    };
    theme =
      let
        mkLiteral = config.lib.formats.rasi.mkLiteral;
      in
      {
        "*" = {
          bg = mkLiteral "#${palette.base00}99";
          bc = mkLiteral "#${palette.base0F}";
          fg = mkLiteral "#${palette.base0D}";
          background-color = mkLiteral "transparent";
        };

        "#window" = {
          background-color = mkLiteral "@bg";
          location = mkLiteral "center";
          width = mkLiteral "30%";
          border-radius = "10px";

        };

        "#prompt" = {
          text-color = mkLiteral "@fg";
        };
        "#textbox-prompt-colon" = {
          text-color = mkLiteral "@fg";
        };

        "#entry" = {
          text-color = mkLiteral "@fg";
          blink = mkLiteral "true";
        };
        "#inputbar" = {
          children = mkLiteral "[ prompt, entry ]";
          text-color = mkLiteral "@fg";
          padding = mkLiteral "5px";
        };
        "#listview" = {
          columns = mkLiteral "1";
          lines = mkLiteral "6";
          cycle = mkLiteral "true";
          dynamic = mkLiteral "true";
        };
        "#mainbox" = {
          border = mkLiteral "3px";
          border-color = mkLiteral "@bc";
          children = mkLiteral "[ inputbar, listview ]";
          padding = mkLiteral "10px";
        };
        "#element" = {
          text-color = mkLiteral "@fg";
          padding = mkLiteral "5px";
        };

        "#element-icon" = {
          text-color = mkLiteral "@fg";
          size = mkLiteral "32px";
        };

        "#element-text" = {
          text-color = mkLiteral "@fg";
          padding = mkLiteral "5px";
        };

        "#element selected" = {
          border = mkLiteral "3px";
          border-color = mkLiteral "@bc";
          text-color = mkLiteral "@fg";
          background-color = mkLiteral "@bc";
        };
      };
  };
}

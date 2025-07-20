{
  pkgs,
  config,
  ...
}:
with pkgs;
let
  palette = config.lib.stylix.colors;
in
{
  home.packages =[
      rofi-file-browser
      rofi-pass-wayland
      rofi-pulse-select
      rofi-systemd
      rofi-calc
  ];
  programs.rofi = {
    enable = true;
    font = "JetBrains Nerd Font 16";
    package = pkgs.rofi-wayland;
    plugins = [
      rofi-file-browser
      rofi-pass-wayland
      rofi-pulse-select
      rofi-systemd
      rofi-calc

    ];
    pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland;
      stores = [ "/home/nandar/.pass" ];
    };
    extraConfig = {
      case-sensitive = false;
      display-drun = "❄️Apps ";
      display-run = " Run ";
      display-filebrowser = " Files ";
      display-window = " Windows ";
      display-recursivebrowser = "󱞊 MoreFiles ";
      hover-select =true;
      me-select-entry="MousePrimary";
      me-accept-entry="!MousePrimary";     
      scroll-method=0;
      modi = [
        "drun"
        "run"
        "filebrowser"
        "window"
        "recursivebrowser"
      ];
      show-icons = true;
      kb-select-1="Control+1";
      kb-select-2="Control+2";
      kb-select-3="Control+3";
      kb-select-4="Control+4";
      kb-select-5="Control+5";
      kb-select-6="Control+6";
      kb-select-7="Control+7";
      kb-select-8="Control+8";
      kb-select-9="Control+9";
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
          border-radius = mkLiteral "10px";

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

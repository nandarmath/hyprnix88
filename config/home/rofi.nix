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
  home.packages = [
    rofi-file-browser
    rofi-pass-wayland
    rofi-pulse-select
    rofi-systemd
    rofi-calc
  ];
  programs.rofi = {
    enable = true;
    font = "JetBrains Nerd Font 16";
    package = n-rofi.rofi;
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
      display-drun = "  Apps ";
      display-run = " Run ";
      display-filebrowser = " Files ";
      display-window = " Windows ";
      display-recursivebrowser = "󱞊 MoreFiles ";
      hover-select = true;
      me-select-entry = "MousePrimary";
      me-accept-entry = "!MousePrimary";
      scroll-method = 0;
      modi = [
        "drun"
        "run"
        "filebrowser"
        "window"
        "recursivebrowser"
      ];
      show-icons = true;
      kb-select-1 = "Control+1";
      kb-select-2 = "Control+2";
      kb-select-3 = "Control+3";
      kb-select-4 = "Control+4";
      kb-select-5 = "Control+5";
      kb-select-6 = "Control+6";
      kb-select-7 = "Control+7";
      kb-select-8 = "Control+8";
      kb-select-9 = "Control+9";
    };
    theme =
      let
        mkLiteral = config.lib.formats.rasi.mkLiteral;
      in
      {
        "*" = {
          bg0 = mkLiteral "#${palette.base00}";
          bg1 = mkLiteral "#${palette.base01}";
          bg2 = mkLiteral "#${palette.base02}";
          bg3 = mkLiteral "#${palette.base03}";
          fg0 = mkLiteral "#${palette.base04}";
          fg1 = mkLiteral "#${palette.base05}";
          fg2 = mkLiteral "#${palette.base06}";
          fg3 = mkLiteral "#${palette.base09}";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@fg2";
          margin = mkLiteral "0px";
          padding = mkLiteral "0px";
          spacing = mkLiteral "0px";
        };

        "#window" = {
          background-color = mkLiteral "@bg0";
          location = mkLiteral "center";
          width = mkLiteral "30%";
          border-radius = mkLiteral "24px";

        };

        "#prompt" = {
          text-color = mkLiteral "@fg2";
        };
        "#textbox" = {
          padding = mkLiteral "8px 24px";
        };

        "#entry" = {
          placeholder = mkLiteral "'Search'";
          placeholder-color = mkLiteral "@fg3";
        };
        "#message" = {
          margin = mkLiteral "12px 0 0";
          border-radius = mkLiteral "16px";
          border-color = mkLiteral "@bg2";
          background-color = mkLiteral "@bg2";
        };
        "#inputbar" = {
          children = mkLiteral "[ prompt, entry ]";
          padding = mkLiteral "8px 16px";
          spacing = mkLiteral "8px";
          background-color = mkLiteral "@bg1";
          border-color = mkLiteral "@fg3";
          border = mkLiteral "2px";
          border-radius = mkLiteral "16px";
        };
        "#listview" = {
          background-color = mkLiteral "transparent";
          columns = mkLiteral "1";
          lines = mkLiteral "8";
          fixed-height = mkLiteral "false";
        };
        "#mainbox" = {
          padding = mkLiteral "12px";
        };
        "#element" = {
          padding = mkLiteral "8px 16px";
          spacing = mkLiteral "8px";
          border-radius = mkLiteral "16px";
        };
        "#element normal active" = {
          text-color = mkLiteral "@bg3";
        };

        "#element alternate active" = {
          text-color = mkLiteral "@bg3";
        };
        "#element selected normal, element selected active" = {
          background-color = mkLiteral "@fg3";
        };

        "#element-icon" = {
          size = mkLiteral "1em";
          vertical-align = mkLiteral "0.5";
        };
        "#element-text" = {
          text-color = mkLiteral "inherit";
        };

      };
  };
}

{
  pkgs,
  config,
  ...
}: let
  palette = config.lib.stylix.colors;
in {
  programs.rofi = {
    package = pkgs.rofi.override {plugins = [pkgs.rofi-calc pkgs.rofi-file-browser];};
    plugins = [ pkgs.rofi-wayland];
  };
  home.file.".config/rofi/config.rasi".text = ''
    @theme "/dev/null"

    * {
      bg: #${palette.base00}99;
      background-color: @bg;
    }
    
    configuration {
        modi:                       "drun,run,filebrowser,window,recursivebrowser";
        show-icons:	                true;
        icon-theme:	                "Yaru-dark";
        location:		                0;
        font:		                    "JetBrains Nerd Font 16";
        display-drun:               " Apps";
        display-run:                " Run";
        display-filebrowser:        " Files";
        display-window:             " Windows";
        display-recursivebrowser:   "󱞊 MoreFiles";
        drun-display-format:        "{name}";
        hover-select:               true;
        me-select-entry:            "MousePrimary";
        me-accept-entry:            "!MousePrimary";     
        window-format:              "{w} · {c} · {t}";
   }

/*****----- Global Properties -----*****/

* {
    border-colour:               #${palette.base0F};
}

/*****----- Main Window -----*****/
window {
    /* properties for window widget */
    transparency:                "real";
    location:                    center;
    anchor:                      center;
    fullscreen:                  false;
    width:                       45%;
    x-offset:                    0px;
    y-offset:                    0px;

    /* properties for all widgets */
    enabled:                     true;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               10px;
    border-color:                @border-colour;
    cursor:                      "default";
}

/*****----- Main Box -----*****/
mainbox {
    enabled:                     true;
    spacing:                     0px;
    margin:                      0px;
    padding:                     20px;
    border:                      0px solid;
    border-radius:               0px 0px 0px 0px;
    border-color:                @border-colour;
    background-color:            transparent;
    children:                    [ "inputbar", "message", "mode-switcher", "listview" ];
}

/*****----- Inputbar -----*****/
inputbar {
    enabled:                     true;
    spacing:                     10px;
    margin:                      0px 0px 10px 0px;
    padding:                     5px 10px;
    border:                      0px solid;
    border-radius:               10px;
    border-color:                @border-colour;
    children:                    [ "textbox-prompt-colon", "entry" ];
}

prompt {
    enabled:                     true;
    background-color:            inherit;
    text-color:                  #${palette.base0D};
}
textbox-prompt-colon {
    enabled:                     true;
    padding:                     5px 0px;
    expand:                      false;
    str:                         "";
    background-color:            inherit;
    text-color:                  inherit;
}
entry {
    enabled:                     true;
    padding:                     5px 0px;
    background-color:            inherit;
    text-color:                  #${palette.base05};
    cursor:                      text;
    placeholder:                 "Search...";
    placeholder-color:           inherit;
}
num-filtered-rows {
    enabled:                     true;
    expand:                      false;
    background-color:            inherit;
    text-color:                  inherit;
}
textbox-num-sep {
    enabled:                     true;
    expand:                      false;
    str:                         "/";
    background-color:            inherit;
    text-color:                  inherit;
}
num-rows {
    enabled:                     true;
    expand:                      false;
    background-color:            inherit;
    text-color:                  inherit;
}
case-indicator {
    enabled:                     true;
    background-color:            inherit;
    text-color:                  inherit;
}

/*****----- Listview -----*****/
listview {
    enabled:                     true;
    columns:                     1;
    lines:                       8;
    cycle:                       true;
    dynamic:                     true;
    scrollbar:                   false;
    layout:                      vertical;
    reverse:                     false;
    fixed-height:                true;
    fixed-columns:               true;
    
    spacing:                     5px;
    margin:                      0px;
    padding:                     10px;
    border:                      0px 2px 2px 2px ;
    border-radius:               0px 0px 10px 10px;
    border-color:                @border-colour;
    background-color:            transparent;
    cursor:                      "default";
}
scrollbar {
    handle-width:                5px ;
    border-radius:               10px;
}

/*****----- Elements -----*****/
element {
    enabled:                     true;
    spacing:                     10px;
    margin:                      0px;
    padding:                     6px;
    border:                      0px solid;
    border-radius:               6px;
    border-color:                @border-colour;
    background-color:            transparent;
    text-color:                  #${palette.base05};
    cursor:                      pointer;
}
element selected.normal {
    background-color:            #${palette.base0C};
    text-color:                  #${palette.base01};
}
element-icon {
    background-color:            transparent;
    text-color:                  inherit;
    size:                        24px;
    cursor:                      inherit;
}
element-text {
    background-color:            transparent;
    text-color:                  inherit;
    highlight:                   inherit;
    cursor:                      inherit;
    vertical-align:              0.5;
    horizontal-align:            0.0;
}

/*****----- Mode Switcher -----*****/
mode-switcher{
    enabled:                     true;
    expand:                      false;
    spacing:                     0px;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                #${palette.base0F};
    background-color:            transparent;
}
button {
    padding:                     10px;
    border:                      0px 0px 2px 0px ;
    border-radius:               10px 10px 0px 0px;
    border-color:                @border-colour;
    background-color:            @bg;
    text-color:                  #${palette.base01};
    cursor:                      pointer;
}
button selected {
    border:                      2px 2px 0px 2px ;
    border-radius:               10px 10px 0px 0px;
    border-color:                @border-colour;
    text-color:                  #${palette.base0F};
}

/*****----- Message -----*****/
message {
    enabled:                     true;
    margin:                      0px 0px 10px 0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px 0px 0px 0px;
    border-color:                @border-colour;
    background-color:            transparent;
}
textbox {
    padding:                     10px;
    border:                      0px solid;
    border-radius:               10px;
    border-color:                @border-colour;
    text-color:                  #${palette.base0F};
    vertical-align:              0.5;
    horizontal-align:            0.0;
    highlight:                   none;
    blink:                       true;
    markup:                      true;
}
error-message {
    padding:                     10px;
    border:                      2px solid;
    border-radius:               10px;
    border-color:                @border-colour;
}
    '';
}

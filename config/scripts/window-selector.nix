{ pkgs }:

pkgs.writeShellScriptBin "window-selector" ''
WINDOW=$(hyprctl clients | grep "class: " | awk '{gsub("class: ", "");print}' | rofi -dmenu -p "Choose Window" --sort true )
if [ "$WINDOW" = "" ]; then
    exit
fi
hyprctl dispatch focuswindow $WINDOW
''

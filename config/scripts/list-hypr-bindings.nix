{ pkgs, ... }:

let
  inherit ( import ../../options.nix ) terminal browser;
in
pkgs.writeShellScriptBin "list-hypr-bindings" ''
  yad --width=800 --height=650 \
  --center \
  --fixed \
  --title="Hyprland Keybindings" \
  --no-buttons \
  --list \
  --column=Key: \
  --column=Description: \
  --column=Command: \
  --timeout=90 \
  --timeout-indicator=right \
  " = Windows/Super/CAPS LOCK" "Modifier Key, used for keybindings" "Doesn't really execute anything by itself." \
  " + A" "Rofi App Launcher" "rofi -show drun" \
  " + B" "Rofi Bluetooth" "Bluetooth" \
  " + M " "Launch Emoji Selector" "emopicker9000" \
  " + S" "Take Screenshot" "screenshootin" \
  " + D" "Launch Discord" "discord" \
  " + O" "Launch OBS" "obs" \
  " + G" "Launch GIMP" "gimp" \
  " + E" "Launch New File Browser Window" "thunar" \
  " +  " "Launch Spotify" "spotify" \
  " + P" "Pseudo Tiling" "pseudo" \
  " + Q" "Launch Terminal" "Alacritty" \
  " + F" "Toggle Focused Fullscreen" "fullscreen" \
  " + R" "Launch LibreOffice writer" "Writer" \
  " + C" "Launch LibreOffice Calc" "Calc" \
  " + V" "Launch Clip History" "wf-clip" \
  " + W" "Launch Web Browser" "${browser}" \
  " + X" "Kill Focused Window" "killactive" \
  " + Y" "Lauch Youtube Cli" "ytfzf" \
  " + Z" "Quit / Exit Hyprland" "exit" \
  " + Plus" "Go To Special Workspace" "movetoworkspace" \
  " + Minus" "Add To Special Workspace" "Add to Scpesial" \
  " + ENTER" "Launch Terminal" "Kitty" \
  " + Left" "Move Focus To Window On The Left" "movefocus,l" \
  " + Right" "Move Focus To Window On The Right" "movefocus,r" \
  " + Up" "Move Focus To Window On The Up" "movefocus,u" \
  " + Down" "Move Focus To Window On The Down" "movefocus,d" \
  " + CONTROL + R" "Record Screen" "Screen Record" \
  " + CONTROL + C" "Calendar CLi" "calcure" \
  " + SHIFT+ C" "Calculator" "calker" \
  " + SHIFT + F" "Toggle Focused Floating" "fullscreen" \
  " + SHIFT + I" "Toggle Split Direction" "togglesplit" \
  " + SHIFT + W" "Search Websites Like Nix Packages" "web-search" \
  " + SHIFT + N" "Watch TV" "TV" \
  " + SHIFT + M" "Dmenu Mager" "Mager" \
  " + SHIFT + R" "Stop Wf-recorder" "Kill Record" \
  " + SHIFT + P" "Launch Color Picker" "picker" \
  " + SHIFT + Left" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + Right" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + Up" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + Down" "Move Focused Window Down" "movewindow,d" \
  " + H" "Move Focus To Window On The Left" "movefocus,l" \
  " + L" "Move Focus To Window On The Right" "movefocus,r" \
  " + K" "Move Focus To Window On The Up" "movefocus,u" \
  " + J" "Move Focus To Window On The Down" "movefocus,d" \
  " + SHIFT + H" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + L" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + K" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + J" "Move Focused Window Down" "movewindow,d" \
  " + SPACE" "Toggle Special Workspace" "togglespecialworkspace" \
  " + SHIFT + SPACE" "Send Focused Window To Special Workspace" "movetoworkspace,special" \
  " + 1-0" "Move To Workspace 1 - 10" "workspace,X" \
  " + SHIFT + 1-0" "Move Focused Window To Workspace 1 - 10" "movetoworkspace,X" \
  " + MOUSE_LEFT" "Move/Drag Window" "movewindow" \
  " + MOUSE_RIGHT" "Resize Window" "resizewindow" \
  "ALT + TAB" "Cycle Window Focus + Bring To Front" "cyclenext & bringactivetotop" \
  ""
''

{pkgs}:
pkgs.writeShellScriptBin "dock" ''

  #!/bin/bash

  if pgrep -f "nwg-dock-hyprland" > /dev/null
  then
      pkill -f "nwg-dock-hyprland"
  else
    nwg-dock-hyprland -i 32 -w 10 -hl top -hd 0 -mb 10 -ml 10 -mr 10 -x -g "kitty-dropterm" -c "rofi -show drun" -lp start -d -l top
  fi

''

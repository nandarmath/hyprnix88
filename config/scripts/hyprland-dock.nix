{pkgs}:
pkgs.writeShellScriptBin "dock" ''

  #!/bin/bash

  if pgrep -f "nwg-dock-hyprland" > /dev/null
  then
      pkill -f "nwg-dock-hyprland"
  else
  #  nwg-dock-hyprland -i 40 -x -mb 10 -w 3 -nolauncher
    nwg-dock-hyprland -i 32 -w 5 -mb 10 -ml 10 -mr 10 -x -g "kitty-dropterm" -c  "nwg-drawer -mb 100 -mt 100 -ml 300 -mr 300"

  fi

''

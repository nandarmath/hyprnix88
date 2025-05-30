#!/bin/bash
# File              : dmenu_mpc
# License           : MIT License
# Author            : M. Nabil Adani <nblid48[at]gmail[dot]com>
# Date              : Sabtu, 12/06/2021 19:49 WIB
# Last Modified Date: Sabtu, 12/06/2021 19:49 WIB
# Last Modified By  : M. Nabil Adani <nblid48[at]gmail[dot]com>

{ pkgs }:

pkgs.writeShellScriptBin "dmenu_mpc" ''
DMENU="rofi -dmenu -i"

function getPlaylist() {
    mpc playlist -f "[%position%];[[%title%;[%artist%]]|[%file%]]" | column -t -s ";"| $DMENU -p " MPD" | cut -d " " -f 1
}

play=$(getPlaylist)

if [ -n $play ]; then
    mpc play $play
fi
''

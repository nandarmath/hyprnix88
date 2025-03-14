#!/bin/bash
# File              : dmenu_aria2
# License           : MIT License
# Author            : M. Nabil Adani <nblid48@gmail.com>
# Date              : Rabu, 06/11/2019 04:51 WIB
# Last Modified Date: Kamis, 23/04/2020 12:51 WIB
# Last Modified By  : M. Nabil Adani <nblid48@gmail.com>


# required
# 1. aria2p (https://github.com/pawamoy/aria2p)
# 2. clipmenu (https://github.com/cdown/clipmenu)

{pkgs}:
pkgs.writeShellScriptBin "dmenu_aria" ''
DMENU="rofi -dmenu -i -p Download"
ARIA2URI="http://localhost:6800/jsonrpc"

function datagen() {
    jq -n --arg id "$(date +%N)" --arg url "$1" \
        '{ "jsonrpc": "2.0", "id": $id, "method":"aria2.addUri", "params":[[$url]], }'
}

url=$(cat /tmp/clipmenu/*/line_cache | sort -r | cut -c 21- | grep -Po '(http|https|ftp|ftps):\/\/\w.+' | $DMENU)
# url=$(clipdel '^http[s]:\/\/.*' | sort -r | dmenu -p Aria2 "$@")
if [[ ! -z $url ]]; then
    notify-send "Aria2 | Downloading" "$url" -u normal
    data=$(datagen "$url")
    curl -s --request POST --url $ARIA2URI --header 'Content-Type: application/json' --data "$data"
fi
''

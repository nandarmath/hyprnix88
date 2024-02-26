{ pkgs }:

pkgs.writeShellScriptBin "dmenu-mager" ''

# File              : dmenu_mager
# License           : MIT License
# Author            : M. Nabil Adani <nblid48@gmail.com>
# Date              : Jumat, 15/05/2020 13:12 WIB
# Last Modified Date: Minggu, 11/10/2020 12:44 WIB
# Last Modified By  : M. Nabil Adani <nblid48@gmail.com>

DMENU="rofi -dmenu -i -p Mager"
# OPTIONS = [[label, command]]
OPTIONS='''
[
  [ "aria2",                  "dmenu_aria2" ],
  [ "droidcam audio only",    "droidcam-cli -a 192.168.43.1 4747 &" ],
  [ "droidcam video & audio", "droidcam-cli -a -v 192.168.43.1 4747 &" ],
  [ "droidcam video only",    "droidcam-cli 192.168.43.1 4747 &" ],
  [ "play video0",            "mpv --no-audio --window-scale=0.5 av://v4l2:/dev/video0 --vf=hflip --profile=low-latency --untimed" ],
  [ "play video1",            "mpv --no-audio --window-scale=0.5 av://v4l2:/dev/video1 --vf=hflip --profile=low-latency --untimed" ],
  [ "kill",                   "dmenu_kill" ],
  [ "kill droidcam",          "pkill droidcam-cli" ],
  [ "mpv",                    "dmenu_mpv" ],
  [ "screenshot",             "dmenu_screenshot" ],
  [ "systemd",                "dmenu_systemd" ],
  [ "translate",              "dmenu_translate -i" ],
  [ "udiskie",                "dmenu_udiskie -matching regex -dmenu -i -no-custom -multi-select -p FlashDrive" ],
  [ "youtube",                "ytfzf -fDH" ],
  [ "umount iso",             "dmenu_iso" ],
  [ "photopea",               "chromium --new-window --app=https://www.photopea.com/" ],
  [ "trello",                 "chromium --new-window --app=https://trello.com/" ],
  [ "facebook",               "chromium --new-window --app=https://m.facebook.com/" ],
  [ "Siakad",                 "chromium --new-window --app=https://siakad.uny.ac.id/" ],
  [ "Ekinerja BKN",           "chromium --new-window --app=https://kinerja.bkn.go.id/" ],
  [ "PMM",                    "chromium --new-window --app=https://guru.kemdikbud.go.id/" ],
  [ "BeSmart UNY",            "chromium --new-window --app=https://besmart.uny.ac.id/" ],
  [ "E-Monev BPI",            "chromium --new-window --app=https://beasiswa.kemdikbud.go.id/monev" ],
  [ "tweetDeck",              "chromium --new-window --app=https://tweetdeck.twitter.com/" ],
  [ "figma",                  "chromium --new-window --app=https://www.figma.com/files/drafts" ],
  [ "iptv",                   "dmenu_iptv" ],
  [ "virtual session",        "dmenu_virtualsession" ],
  [ "dns switcher",           "dmenu_dns"],
  [ "adb clipoard",           "adbclip"]
]
  '''

label=$(echo $OPTIONS | jq -r "sort | .[][0]" | $DMENU)
exec $(echo $OPTIONS | jq -r ".[] | select(.[0] == \"$label\") | .[1]")

''
pkgs.writeShellScriptBin "dmenu-docker" ''
DMENU="rofi -dmenu -i -p Docker"

function get_container() {
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | $DMENU -selected-row 1 -theme-str "window {width: 55%;}"
}

function menu() {
    OPTIONS='["Start", "Stop", "Restart"]'
    select=$(echo $OPTIONS | jq -r ".[]" | $DMENU -mesg "Container Name : $1" -theme-str 'window {width: 30%;} listview {lines: 1; columns:3;} element-text {horizontal-align: 0.5;}')
    if [ "$select" = "Stop" ]; then
        docker container stop $1 && notify-send "Docker" "Stop : $1"
    elif [ "$select" = "Restart" ]; then
        docker container restart $1 && notify-send "Docker" "Restart : $1"
    elif [ "$select" = "Start" ]; then
        docker container start $1 && notify-send "Docker" "Start : $1"
    fi
}

if [ -f "/run/docker.pid" ]; then
    container=$(get_container)
    if [ "$container" != "" ]; then
        container_name=$(echo $container | cut -d " " -f 2)
        menu $container_name
    fi
else
    notify-send "Docker" "Docker is not running"
fi
''




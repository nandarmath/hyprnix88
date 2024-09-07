#!/bin/bash
# File              : dmenu_iptv
# License           : MIT License
# Author            : M. Nabil Adani <nblid48@gmail.com>
# Date              : Senin, 01/02/2021 11:52 WIB
# Last Modified Date: Senin, 01/02/2021 11:52 WIB
# Last Modified By  : M. Nabil Adani <nblid48@gmail.com>

{ pkgs }:

pkgs.writeShellScriptBin "dmenu_iptv" ''
DMENU="rofi -dmenu -i"
IPTV=''''
[
    ["BERITA SATU 480p",  "https://b1news.beritasatumedia.com/Beritasatu/B1News_960x540.m3u8"],
    ["BERITA SATU 720p",  "https://b1news.beritasatumedia.com/Beritasatu/B1News_1280x720.m3u8"],
    ["CNBN INDONESIA",    "https://live.cnbcindonesia.com/livecnbc/smil:cnbctv.smil/chunklist_w1352897452_b280000_sleng.m3u8"],
    ["CNN INDONESIA",     "https://live.cnnindonesia.com/livecnn/smil:cnntv.smil/playlist.m3u8"],
    ["I News",            "https://vcdn2.rctiplus.id/live/eds/inews_fta/live_fta/inews_fta-avc1_1537200=6-mp4a_64000_eng=2.m3u8"],
    ["K+",                "http://210.210.155.35/uq2663/h/h08/index.m3u8"],
    ["KIX",               "http://45.126.83.51/uq2663/h/h07/01.m3u8"],
    ["METRO TV",          "https://youtu.be/XZbGxBY-c1o"],
    ["MNCTV",             "https://vcdn2.rctiplus.id/live/eds/mnctv_fta/live_fta/mnctv_fta.m3u8"],
    ["MY KIDS",           "http://210.210.155.35/qwr9ew/s/s30/index2.m3u8"],
    ["NET TV",            "https://youtu.be/e4Tn_VUFpkg"],
    ["NICKELODEON HD",    "https://nonton.site:8443/provision/pp/37404"],
    ["RCTI",              "https://vcdn2.rctiplus.id/live/eds/rcti_fta/live_fta/rcti_fta.m3u8"],
    ["RTV",               "https://livestreaming-google-etslive.vidio.com/hls-p/ingest_1561_720p/index.m3u8"],
    ["SCTV",              "https://livestreaming-google-etslive.vidio.com/hls-p/ingest_204_720p/index.m3u8"],
    ["THRILL",            "http://45.126.83.51/qwr9ew/s/s34/index2.m3u8"],
    ["TRANS 7",           "https://video.detik.com/trans7/smil:trans7.smil/playlist.m3u8"],
    ["TRANS TV",          "https://video.detik.com/transtv/smil:transtv.smil/playlist.m3u8"],
    ["TVN MOVIE",         "https://nonton.site:8443/provision/pp/927"],
    ["TVONE",             "https://youtu.be/yNKvkPJl-tg"],
    ["RAI ITALIA",        "http://210.210.155.35/x6bnqe/s/s63/S4/mnf.m3u8"]
]
''''

channel=$(echo $IPTV | jq -r "sort | .[][0]" | $DMENU -p "癩 IPTV")
url=$(echo $IPTV | jq -r ".[] | select(.[0] == \"$channel\") | .[1]")

if [[ $channel != "" ]]; then
    notify-send "DMENU_IPTV" "Current Playing $channel"
    mpv --title="$channel | IPTV" "$url" &
fi

''

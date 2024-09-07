#!/bin/bash
# File              : dmenu_mager
# License           : MIT License
# Author            : M. Nabil Adani <nblid48@gmail.com>
# Date              : Jumat, 15/05/2020 13:12 WIB
# Last Modified Date: Minggu, 11/10/2020 12:44 WIB
# Last Modified By  : M. Nabil Adani <nblid48@gmail.com>
{ pkgs }:

pkgs.writeShellScriptBin "dmenu-mager" ''
  DMENU="rofi -dmenu -i -p Mager"
  # OPTIONS = [[label, command]]
  OPTIONS=''''
  [
    [ "boottester",             "dmenu_boottester" ],
    [ "droidcam audio only",    "droidcam-cli -a 192.168.43.1 4747 &" ],
    [ "droidcam video & audio", "droidcam-cli -a -v 192.168.43.1 4747 &" ],
    [ "droidcam video only",    "droidcam-cli 192.168.43.1 4747 &" ],
    [ "play video0",            "mpv --no-audio --window-scale=0.5 av://v4l2:/dev/video0 --vf=hflip --profile=low-latency --untimed" ],
    [ "play video1",            "mpv --no-audio --window-scale=0.5 av://v4l2:/dev/video1 --vf=hflip --profile=low-latency --untimed" ],
    [ "kill",                   "dmenu_kill" ],
    [ "kill droidcam",          "pkill droidcam-cli" ],
    [ "monitor",                "dmenu_monitor" ],
    [ "translate",              "translate" ],
    [ "mpdmenu",                "dmenu_mpdmenu" ],
    [ "mpv",                    "dmenu_mpv" ],
    [ "pass",                   "dmenu_pass -p \"Pass Man\"" ],
    [ "power",                  "dmenu_power" ],
    [ "qutebrowser",            "dmenu_qutebrowser" ],
    [ "record",                 "dmenu_record" ],
    [ "droidapps",              "droidapps" ],
    [ "switcher",               "dmenu_switcher" ],
    [ "systemd",                "dmenu_systemd" ],
    [ "todo",                   "dmenu_todo" ],
    [ "translate-input",        "dmenu_translate -i" ],
    [ "udiskie",                "dmenu_udiskie -matching regex -dmenu -i -no-custom -multi-select -p FlashDrive" ],
    [ "wifi",                   "dmenu_wifi" ],
    [ "window",                 "dmenu_window" ],
    [ "youtube",                "ytfzf -fDH" ],
    [ "umount iso",             "dmenu_iso" ],
    [ "photopea",               "firefox --new-window --app=https://photopea.com/" ],
    [ "Chat GPT",               "brave --app=https://chat.openai.com/" ],
    [ "Gemini",                 "brave --app=https://gemini.google.com/" ],
    [ "Zoom Meeting",           "firefox --new-window --app=https://zoom.us/id/join/" ],
    [ "Matlab",                 "brave --app=https://matlab.mathworks.com/" ],
    [ "Remaker AI",             "brave --app=https://remaker.ai/" ],
    [ "Blackbox AI",            "brave --app=https://blackbox.ai/" ],
    [ "CLaude AI",              "brave --app=https://claude.ai/" ],
    [ "Canva",                  "brave --app=https://canva.com/" ],
    [ "HIX AI",                 "brave --app=https://hix.ai/" ],
    [ "Any Summary",            "brave --app=https://anysummary.app/" ],
    [ "Remove Object Photo",    "brave --app=https://photoroom.com/" ],
    [ "whatsapp",               "brave --app=https://web.whatsapp.com/" ],
    [ "Image Creator AI",       "brave --app=https://bing.com/images/create/" ],
    [ "Prepostseo (Parafrase)", "brave --app=https://prepostseo.com/" ],
    [ "Perplexity",             "brave --app=https://perplexity.ai/" ],
    [ "Consensus",              "brave --app=https://consensus.app/" ],
    [ "Shortly AI",             "brave --app=https://shortlyai.com/" ],
    [ "Transcription Cockatoo", "brave --app=https://cockatoo.com/" ],
    [ "Jenni",                  "brave --app=https://jenni.ai/" ],
    [ "Open Knowledges Maps",   "brave --app=https://openknowledgemaps.org/" ],
    [ "Research rabbit",        "brave --app=https://researchrabbit.ai/" ],
    [ "Connected Paper",        "brave --app=https://connectedpapers.com/" ],
    [ "Grammarly",              "brave --app=https://grammarly.com/" ],
    [ "Humata - Review Jurnal", "brave --app=https://humata.ai/" ],
    [ "sci-hub (Open lock Journal)", "brave --app=https://sci-hub.se/" ],
    [ "Quillbot",               "brave --app=https://quillbot.com/" ],
    [ "Elicit (Ans With Journal)",   "brave --app=https://elicit.com/" ],
    [ "Bai ChatBOT",            "brave --app=https://chatbot.theb.ai/" ],
    [ "Open Asset",             "firefox --new-window --app=https://openverse.org/" ],
    [ "Ekinerja",               "firefox --new-window --app=https://kinerja.bkn.go.id/" ],
    [ "PMM",                    "firefox --new-window --app=https://guru.kemdikbud.go.id/" ],
    [ "E-Monev",                "firefox --new-window --app=https://beasiswa.kemdikbud.go.id/monev" ],
    [ "Siakad UNY",             "firefox --new-window --app=https://siakad.uny.ac.id/" ],
    [ "Registrasi UNY",         "firefox --new-window --app=https://registrasi.uny.ac.id/" ],
    [ "BeSmart UNY",            "firefox --new-window --app=https://besmart.uny.ac.id/" ],
    [ "E-Service UNY",          "firefox --new-window --app=https://eservice.uny.ac.id/" ],
    [ "YouTube",                "brave --app=https://youtube.com/" ],
    [ "Pusdapendik",            "firefox --new-window --app=https://pusdapendik.sultengprov.go.id/" ],
    [ "Gitlab",                 "firefox --new-window --app=https://gitlab.com/" ],
    [ "trello",                 "firefox --new-window --app=https://trello.com/" ],
    [ "facebook",               "brave --app=https://m.facebook.com/" ],
    [ "tweetDeck",              "firefox --new-window --app=https://tweetdeck.twitter.com/" ],
    [ "figma",                  "firefox --new-window --app=https://www.figma.com/files/drafts" ],
    [ "iptv",                   "dmenu_iptv" ],
    [ "dmenu_ffmpeg",           "dmenu_ffmpeg" ],
    [ "dmenu_aria",             "dmenu_aria" ],
    [ "rofi-calc",              "roi-calc" ],
    [ "virtual session",        "dmenu_virtualsession" ],
    [ "dns switcher",           "dmenu_dns"],
    [ "adb clipoard",           "adbclip"]
  ]
  ''''
  label=$(echo $OPTIONS | jq -r "sort | .[][0]" | $DMENU)
  exec $(echo $OPTIONS | jq -r ".[] | select(.[0] == \"$label\") | .[1]")

''

#!/bin/bash 
# Dependencies: tesseract-ocr imagemagick scrot xsel rofi



{pkgs}:
pkgs.writeShellScriptBin "translate" ''
set -e

SCR_IMG=$(mktemp)
trap 'rm $SCR_IMG*' EXIT

grim -g "$SCR_IMG.png"
mogrify -modulate 100,0 -resize 400% "$SCR_IMG.png" #should increase detection rate
tesseract "$SCR_IMG.png" "$SCR_IMG" &> /dev/null
cat "$SCR_IMG.txt" > wordy.txt
tr -d '\014' <wordy.txt > words.txt
src=$(cat words.txt)

test "$src" = "$(cat words.txt)"

rofi="rofi -dmenu -yoffset 30 -location 2"

pag() {                                                 \
    sed -e 1d                                           \
        -e 's; _\([A-Z]\); \1;p'                        \
        -e '/^$/d' -e '/^-->/d'                         \
    | eval "$rofi" -l 20 -p 'Done'
}

phrase="$(echo $src | eval "$rofi" -markup -p 'Lookup: ')"
{
    sdcv -n --utf8-input --utf8-output "$phrase"
    printf "Urban\n"
    links -dump "https://www.urbandictionary.com/define.php?term=$phrase" \
        | sed -n '1,/Top def/d;/Get the mug/q;p'
} | pag
''

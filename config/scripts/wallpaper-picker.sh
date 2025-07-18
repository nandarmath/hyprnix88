#!/usr/bin/env bash

wallpapers_folder=$HOME/Pictures/Wallpapers
    
selected=$(for a in $wallpapers_folder/*.*; do echo -en "${a##*/}\0icon\x1f$a\n" ; done | rofi -dmenu -p "Pilih Wallpaper " -theme-str 'element-icon { size: 4em; }')

# Gabungkan dengan path
if [ -n "$selected" ]; then
    full_path="$wallpapers_folder/$selected"
    echo "File yang dipilih: $full_path"
fi
swww img $full_path


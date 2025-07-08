#!/usr/bin/env bash

wallpaper_path=$HOME/Pictures/Wallpapers
wallpapers_folder=$HOME/Pictures/Wallpapers
wallpaper_name="$(ls $wallpapers_folder | rofi -dmenu || pkill rofi)"

if [[ -f $wallpapers_folder/$wallpaper_name ]]; then
    ln -sf "$wallpapers_folder/$wallpaper_name" "$wallpaper_path"
    wall-change "$wallpaper_path"
else
    exit 1
fi

#!/usr/bin/env bash

wallpapers_folder=$HOME/Pictures/Wallpapers
wallpaper_name="$(ls $wallpapers_folder | rofi -dmenu || pkill rofi)"

if [[ -f $wallpapers_folder/$wallpaper_name ]]; then
    swww img "$wallpaper_folder/$wallpaper_name"
    
else
    exit 1
fi

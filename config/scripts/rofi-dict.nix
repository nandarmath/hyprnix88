#!/bin/bash
{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "rofi-dict" ''

# Prompt the user for a word using rofi in dmenu mode
WORD=$(rofi -dmenu -p "Enter a word to look up:")

# Exit if input is empty
if [[ -z "$WORD" ]]; then
    exit 0
fi

# Query the sdvc dictionary for the word's meaning
MEANING=$(sdcv --data-dir ./stardict "$WORD" 2>&1)

# Show the meaning in a rofi message dialog
rofi -e "$WORD: $MEANING"
''

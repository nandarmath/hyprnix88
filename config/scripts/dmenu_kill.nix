#!/bin/sh
{ pkgs }:

pkgs.writeShellScriptBin "dmenu_mpc" ''
ps -ef | sed 1d | rofi -dmenu -i -p "Task Man" "$@" | awk '{print $2}' | xargs kill -${1:-9} ;
''

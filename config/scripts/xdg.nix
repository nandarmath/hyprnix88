{ pkgs }:

pkgs.writeShellScriptBin "xdg_sh" ''

# __  ______   ____ 
# \ \/ /  _ \ / ___|
#  \  /| | | | |  _ 
#  /  \| |_| | |_| |
# /_/\_\____/ \____|
#                   
# ----------------------------------------------------- 
sleep 1

# kill all possible running xdg-desktop-portals
# killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-gnome
killall xdg-desktop-portal-kde
killall xdg-desktop-portal-lxqt
# killall xdg-desktop-portal-wlr
killall xdg-desktop-portal-gtk
# killall xdg-desktop-portal

''

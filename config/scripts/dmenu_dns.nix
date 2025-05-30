#!/bin/bash
# dmenu_dns
# Copyright (c) 2021 M. Nabil Adani <nblid48[at]gmail[dot]com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# required
# - iproute2
# - networkmanager
# - rofi
# - jq
{pkgs}:
pkgs.writeShellScriptBin "dmenu_dns" ''
function get_interface() {
    ip route | grep '^default' | cut -d " " -f 5 | head -1
}

function get_ssid() {
    nmcli device show $(get_interface) | grep CONNECTION | cut -d : -f 2 | tr -d " "
}

function default_dns() {
    ssid=$(get_ssid)
    nmcli connection modify "$ssid" ipv4.method auto
    nmcli connection modify "$ssid" ipv4.ignore-auto-dns false
    nmcli connection up "$ssid" && notify-send "DNS Switcher" "success recconect to $ssid"
}

function change_dns() {
    dns="$1"
    ssid=$(get_ssid)
    nmcli connection modify "$ssid" ipv4.method auto
    nmcli connection modify "$ssid" ipv4.ignore-auto-dns true
    nmcli connection modify "$ssid" ipv4.dns "$dns"
    nmcli connection modify "$ssid" ipv4.dns-search "$dns"
    nmcli connection up "$ssid" && notify-send "DNS Switcher" "success recconect to $ssid"
}

OPTIONS=''''
[
	["DNS Google",     "8.8.8.8"],
	["DNS CloudFlare", "1.1.1.1"],
    ["DNS Quad9",      "9.9.9.9"],
	["DNS Local",      "127.0.0.1"],
    ["Default",        "default"]
]
''''

label=$(echo $OPTIONS | jq -r ".[][0]" | rofi -dmenu -p "DNS Switcher" -theme-str 'window {width: 25%;} listview {lines:5;}')
dns=$(echo $OPTIONS | jq -r ".[] | select(.[0] == \"$label\") | .[1]")

if [ -n "$dns" ]; then
    if [ "$dns" == "default" ]; then
        default_dns
    else
        change_dns "$dns"
    fi
fi
''

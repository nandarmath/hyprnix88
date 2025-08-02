#!/usr/bin/sh

# VirtMon script v1.0
# Script created by Linux Renaissance
# https://www.youtube.com/@LinuxRenaissance
# https://github.com/LinuxRenaissance
# Bring your feedback to our Matrix room
#   https://matrix.to/#/#lr:fosshq.org
# This script is MIT licensed,
# Feel free to offer meaningful PR.
#
# Make sure you configure your headless in hyprland.conf in advance
# Example config:
# monitor=HEADLESS-66,1280x1024@60,2560x450,1.333333

# === FIRST WE REMOVE ALL HEADLESS MONITORS ===
for MON in $(hyprctl monitors | grep HEADLESS | awk '{print $2}'); do
  echo "[wayvnc] Removing $MON..."
  hyprctl output remove "$MON"
done

# === YOU SHOULD EDIT THESE ===
VIRTUAL_MONITOR="HEADLESS-66"
VIRTUAL_WORKSPACE=0
REAL_MONITOR="eDP-1"

# === CLEANUP FUNCTION ===
cleanup() {
  echo "\n[wayvnc] Cleaning up..."
  hyprctl dispatch moveworkspacetomonitor $VIRTUAL_WORKSPACE $REAL_MONITOR
  hyprctl dispatch focusmonitor "$REAL_MONITOR"
  pkill wayvnc
  echo "[wayvnc] Done."
  exit 0
}

# === TRAP EXIT FOR CLEANUP ===
trap cleanup INT TERM EXIT

# === NOW WE CREATE YOUR HEADLESS ===
  echo "[wayvnc] Creating $VIRTUAL_MONITOR..."
  hyprctl output create headless $VIRTUAL_MONITOR
  sleep 0.5

# === ASSIGN WORKSPACE AND ACTIVATE IT ===
echo "[wayvnc] Moving workspace $VIRTUAL_WORKSPACE to $VIRTUAL_MONITOR..."
hyprctl dispatch moveworkspacetomonitor $VIRTUAL_WORKSPACE $VIRTUAL_MONITOR
sleep 0.2
hyprctl dispatch workspace $VIRTUAL_WORKSPACE
sleep 0.2

# === RETURN FOCUS TO YOUR REAL MONITOR SO YOU DON'T GET STUCK ON DELETED ONE ===
hyprctl dispatch focusmonitor "$REAL_MONITOR"

# === FINALLY START WayVNC ===
echo "[wayvnc] Starting WayVNC on $VIRTUAL_MONITOR..."
wayvnc 0.0.0.0 5900 "$VIRTUAL_MONITOR"

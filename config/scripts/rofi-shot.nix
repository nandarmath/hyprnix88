{pkgs ? import <nixpkgs> {}}:

pkgs.writeShellScriptBin "rofi-screenshot" ''
#!/usr/bin/env bash

## rofi-screenshot
## Author: ceuk @ github
## Licence: WTFPL
## Usage:
##    show the menu with rofi-screenshot
##    stop recording with rofi-screenshot -s
## Modified: Menggunakan wl-screenrec untuk merekam layar di Wayland untuk NixOS

# Memastikan semua tools tersedia di PATH
PATH="${pkgs.grim}/bin:${pkgs.slurp}/bin:${pkgs.wl-screenrec}/bin:${pkgs.wl-clipboard}/bin:${pkgs.ffmpeg}/bin:${pkgs.rofi}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.libnotify}/bin:$PATH"

# Screenshot directory
screenshot_directory="''${ROFI_SCREENSHOT_DIR:-''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}"

# Default date format
default_date_format="''${ROFI_SCREENSHOT_DATE_FORMAT:-"+%d-%m-%Y %H:%M:%S"}"

# Pastikan direktori screenshot ada
mkdir -p "$screenshot_directory"

# Convert video to gif using ffmpeg
video_to_gif() {
  ffmpeg -hide_banner -loglevel error -nostdin -i "$1" -vf palettegen -f image2 -c:v png - |
    ffmpeg -hide_banner -loglevel error -nostdin -i "$1" -i - -filter_complex paletteuse "$2"
}

countdown() {
  notify-send --app-name="screenshot" "Screenshot" "Recording in 3" -t 1000
  sleep 1
  notify-send --app-name="screenshot" "Screenshot" "Recording in 2" -t 1000
  sleep 1
  notify-send --app-name="screenshot" "Screenshot" "Recording in 1" -t 1000
  sleep 1
}

crtc() {
  notify-send --app-name="screenshot" "Screenshot" "Select a region to capture"
  grim -g "$(slurp)" /tmp/screenshot_clip.png
  wl-copy < /tmp/screenshot_clip.png
  rm /tmp/screenshot_clip.png
  notify-send --app-name="screenshot" "Screenshot" "Region copied to Clipboard"
}

crtf() {
  notify-send --app-name="screenshot" "Screenshot" "Select a region to capture"
  dt=$1
  grim -g "$(slurp)" "$screenshot_directory/$dt.png"
  notify-send --app-name="screenshot" "Screenshot" "Region saved to ''${screenshot_directory//$HOME/~}/$dt.png"
}

cwtc() {
  notify-send --app-name="screenshot" "Screenshot" "Select a window to capture"
  # Note: In Wayland selecting specific windows requires specific tooling
  # This is a simplified version using region selection
  grim -g "$(slurp)" /tmp/screenshot_clip.png
  wl-copy < /tmp/screenshot_clip.png
  rm /tmp/screenshot_clip.png
  notify-send --app-name="screenshot" "Screenshot" "Window copied to Clipboard"
}

cwtf() {
  notify-send --app-name="screenshot" "Screenshot" "Select a window to capture"
  dt=$1
  # Note: In Wayland selecting specific windows requires specific tooling
  # This is a simplified version using region selection
  grim -g "$(slurp)" "$screenshot_directory/$dt.png"
  notify-send --app-name="screenshot" "Screenshot" "Window saved to ''${screenshot_directory//$HOME/~}/$dt.png"
}

cstc() {
  grim /tmp/screenshot_clip.png
  wl-copy < /tmp/screenshot_clip.png
  rm /tmp/screenshot_clip.png
  notify-send --app-name="screenshot" "Screenshot" "Screenshot copied to Clipboard"
}

cstf() {
  dt=$1
  grim "$screenshot_directory/$dt.png"
  notify-send --app-name="screenshot" "Screenshot" "Saved to ''${screenshot_directory//$HOME/~}/$dt.png"
}

rgrtf() {
  notify-send --app-name="screenshot" "Screenshot" "Select a region to record"
  dt=$1
  # Melakukan countdown
  geometry=$(slurp)
  countdown
  # Menggunakan wl-screenrec untuk merekam area tertentu
  wl-screenrec -g "$geometry" -f /tmp/screenshot_recording.mp4 &
  pid=$!
  
  # Mengatur handle untuk stop recording
  echo $pid > /tmp/wl-screenrec-pid
  
  # Menunggu user menghentikan recording melalui menu
  notify-send --app-name="screenshot" "Screenshot" "Recording started. Use 'Stop recording' option to finish."
  wait $pid || true
  
  # Proses setelah recording selesai
  if [ -f "/tmp/screenshot_recording.mp4" ]; then
    notify-send --app-name="screenshot" "Screenshot" "Converting to gif… (can take a while)"
    video_to_gif /tmp/screenshot_recording.mp4 "$screenshot_directory/$dt.gif"
    rm /tmp/screenshot_recording.mp4
    notify-send --app-name="screenshot" "Screenshot" "Saved to ''${screenshot_directory//$HOME/~}/$dt.gif"
  fi
}

rgstf() {
  dt=$1
  countdown
  # Merekam seluruh layar
  wl-screenrec -f /tmp/screenshot_recording.mp4 &
  pid=$!
  
  # Mengatur handle untuk stop recording
  echo $pid > /tmp/wl-screenrec-pid
  
  # Menunggu user menghentikan recording melalui menu
  notify-send --app-name="screenshot" "Screenshot" "Recording started. Use 'Stop recording' option to finish."
  wait $pid || true
  
  # Proses setelah recording selesai
  if [ -f "/tmp/screenshot_recording.mp4" ]; then
    notify-send --app-name="screenshot" "Screenshot" "Converting to gif… (can take a while)"
    video_to_gif /tmp/screenshot_recording.mp4 "$screenshot_directory/$dt.gif"
    rm /tmp/screenshot_recording.mp4
    notify-send --app-name="screenshot" "Screenshot" "Saved to ''${screenshot_directory//$HOME/~}/$dt.gif"
  fi
}

rvrtf() {
  notify-send --app-name="screenshot" "Screenshot" "Select a region to record"
  dt=$1
  # Melakukan countdown
  geometry=$(slurp)
  countdown
  # Menggunakan wl-screenrec untuk merekam area tertentu
  wl-screenrec -g "$geometry" -f "$screenshot_directory/$dt.mp4" &
  pid=$!
  
  # Mengatur handle untuk stop recording
  echo $pid > /tmp/wl-screenrec-pid
  
  # Menunggu user menghentikan recording melalui menu
  notify-send --app-name="screenshot" "Screenshot" "Recording started. Use 'Stop recording' option to finish."
  wait $pid || true
  
  if [ -f "$screenshot_directory/$dt.mp4" ]; then
    notify-send --app-name="screenshot" "Screenshot" "Saved to ''${screenshot_directory//$HOME/~}/$dt.mp4"
  fi
}

rvstf() {
  dt=$1
  countdown
  # Merekam seluruh layar
  wl-screenrec -f "$screenshot_directory/$dt.mp4" &
  pid=$!
  
  # Mengatur handle untuk stop recording
  echo $pid > /tmp/wl-screenrec-pid
  
  # Menunggu user menghentikan recording melalui menu
  notify-send --app-name="screenshot" "Screenshot" "Recording started. Use 'Stop recording' option to finish."
  wait $pid || true
  
  if [ -f "$screenshot_directory/$dt.mp4" ]; then
    notify-send --app-name="screenshot" "Screenshot" "Saved to ''${screenshot_directory//$HOME/~}/$dt.mp4"
  fi
}

stop_recording() {
  if [ -f "/tmp/wl-screenrec-pid" ]; then
    pid=$(cat /tmp/wl-screenrec-pid)
    if ps -p $pid > /dev/null; then
      kill -SIGINT $pid
      rm /tmp/wl-screenrec-pid
      notify-send --app-name="screenshot" "Screenshot" "Recording stopped"
    else
      notify-send --app-name="screenshot" "Screenshot" "No active recording found"
      rm -f /tmp/wl-screenrec-pid
    fi
  else
    notify-send --app-name="screenshot" "Screenshot" "No recording found"
  fi
}

get_options() {
  echo "  Region  Clip"
  echo "  Region  File"
  echo "  Window  Clip"
  echo "  Window  File"
  echo "  Screen  Clip"
  echo "  Screen  File"
  echo "  Region  File (GIF)"
  echo "  Screen  File (GIF)"
  echo "  Region  File (MP4)"
  echo "  Screen  File (MP4)"
  echo "  Stop recording"
}

show_help() {
  echo ### rofi-screenshot
  echo "USAGE: rofi-screenshot [OPTION] <argument>"
  echo "(no option)"
  echo "    show the screenshot menu"
  echo "-s, --stop"
  echo "    stop recording"
  echo "-h, --help"
  echo "    this screen"
  echo "-d, --directory <directory>"
  echo "    set the screenshot directory"
  echo "-t, --timestamp <format>"
  echo "    set the format used for timestamps, in the format the date"
  echo "    command expects (default '+%d-%m-%Y %H:%M:%S')"
}

check_directory() {
  if [[ ! -d $1 ]]; then
    mkdir -p "$1" || {
      echo "Could not create directory!"
      exit 1
    }
  fi
}

main() {
  # rebind long args as short ones
  for arg in "$@"; do
    shift
    case "$arg" in
      '--help') set -- "$@" '-h' ;;
      '--directory') set -- "$@" '-d' ;;
      '--timestamp') set -- "$@" '-t' ;;
      '--stop') set -- "$@" '-s' ;;
      *) set -- "$@" "$arg" ;;
    esac
  done

  # parse short options
  OPTIND=1
  date_format="$default_date_format"
  while getopts "hd:t:s" opt; do
    case "$opt" in
      'h')
        show_help
        exit 0
        ;;
      'd')
        check_directory $OPTARG
        screenshot_directory="$OPTARG"
        ;;
      't')
        date_format="$OPTARG"
        ;;
      's')
        stop_recording
        exit 0
        ;;
      '?')
        show_help
        exit 1
        ;;
    esac
  done
  shift $(expr $OPTIND - 1)

  # Get choice from rofi
  choice=$( (get_options) | rofi -dmenu -i -fuzzy -p "Screenshot")

  # If user has not picked anything, exit
  if [[ -z "''${choice// /}" ]]; then
    exit 1
  fi

  cmd='date "''${date_format}"'
  dt=$(eval $cmd)

  # run the selected command
  case $choice in
    '  Region  Clip')
      crtc
      ;;
    '  Region  File')
      crtf "$dt"
      ;;
    '  Window  Clip')
      cwtc
      ;;
    '  Window  File')
      cwtf "$dt"
      ;;
    '  Screen  Clip')
      cstc
      ;;
    '  Screen  File')
      cstf "$dt"
      ;;
    '  Region  File (GIF)')
      rgrtf "$dt"
      ;;
    '  Screen  File (GIF)')
      rgstf "$dt"
      ;;
    '  Region  File (MP4)')
      rvrtf "$dt"
      ;;
    '  Screen  File (MP4)')
      rvstf "$dt"
      ;;
    '  Stop recording')
      stop_recording
      ;;
  esac
}

main "$@"
''

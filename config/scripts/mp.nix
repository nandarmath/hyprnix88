{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.writeShellScriptBin "monitor-projection" ''
  PRIMARY_MONITOR="eDP-1"
  PRIMARY_WIDTH="1920"
  PRIMARY_HEIGHT="1080"
  SCALING_FACTOR="1.5"

  # Fungsi untuk mendapatkan monitor sekunder menggunakan rofi
  get_secondary_monitor() {
    xrandr | awk '/ connected/ {print $1}' | \
    grep -v "$PRIMARY_MONITOR" | \
    rofi -dmenu -i -p "Please select a display source!"
  }

  # Fungsi untuk mendapatkan resolusi monitor
  get_monitor_resolution() {
    local monitor="$1"
    xrandr | awk "/$monitor/ {print \$3}" | cut -d 'x' -f "$2"
  }

  SECONDARY_MONITOR=$(get_secondary_monitor)
  SECONDARY_WIDTH=$(get_monitor_resolution "$SECONDARY_MONITOR" 1)
  SECONDARY_HEIGHT=$(get_monitor_resolution "$SECONDARY_MONITOR" 2)

  if [ -z "$SECONDARY_MONITOR" ]; then
    echo "No monitor selected!"
    exit 1
  fi

  # Opsi proyeksi
  WOFI_OPTIONS="Mirror\nSecondary\nLeft\nRight\nTop\nBottom"
  ANSWER=$(echo -e "$WOFI_OPTIONS" | \
    rofi -dmenu -i -p "How do you want to project?" | \
    tr '[:upper:]' '[:lower:]')

  [ -z "$ANSWER" ] && {
    echo "No option selected!"
    exit 1
  }

  # Fungsi untuk mengatur monitor menggunakan hyprctl
  case "$ANSWER" in
    mirror)
      hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,auto,1
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,auto,1,mirror,"$PRIMARY_MONITOR"
      ;;
    secondary)
      hyprctl keyword monitor "$PRIMARY_MONITOR",disable
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,auto,"$SCALING_FACTOR"
      ;;
    left)
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x0,"$SCALING_FACTOR"
      hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,"$SECONDARY_WIDTH"x0,1
      ;;
    right)
      hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x0,1
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,"$PRIMARY_WIDTH"x0,"$SCALING_FACTOR"
      ;;
    top)
      hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x"$SECONDARY_HEIGHT",1
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x0,"$SCALING_FACTOR"
      ;;
    bottom)
      hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x0,1
      hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x"$PRIMARY_HEIGHT","$SCALING_FACTOR"
      ;;
    *)
      echo "Invalid option!"
      exit 1
      ;;
  esac
''

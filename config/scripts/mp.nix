{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.writeShellScriptBin "monitor-projection" ''
  PRIMARY_MONITOR="eDP-1"
  PRIMARY_WIDTH="1920"
  PRIMARY_HEIGHT="1080"
  SCALING_FACTOR="1.5"

  # Fungsi untuk mendapatkan monitor sekunder menggunakan rofi
  get_secondary_monitor() {
    ${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gawk}/bin/awk '/ connected/ {print $1}' | \
    grep -v "$PRIMARY_MONITOR" | \
    ${pkgs.rofi}/bin/rofi -dmenu -i -p "Please select a display source!"
  }

  # Fungsi untuk mendapatkan resolusi monitor
  get_monitor_resolution() {
    local monitor="$1"
    ${pkgs.xorg.xrandr}/bin/xrandr | ${pkgs.gawk}/bin/awk "/$monitor/ {print \$3}" | ${pkgs.coreutils}/bin/cut -d 'x' -f "$2"
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
    ${pkgs.rofi}/bin/rofi -dmenu -i -p "How do you want to project?" | \
    ${pkgs.coreutils}/bin/tr '[:upper:]' '[:lower:]')

  [ -z "$ANSWER" ] && {
    echo "No option selected!"
    exit 1
  }

  # Fungsi untuk mengatur monitor menggunakan hyprctl
  case "$ANSWER" in
    mirror)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,auto,1
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,auto,1,mirror,"$PRIMARY_MONITOR"
      ;;
    secondary)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",disable
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,auto,"$SCALING_FACTOR"
      ;;
    left)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x0,"$SCALING_FACTOR"
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,"$SECONDARY_WIDTH"x0,1
      ;;
    right)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x0,1
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,"$PRIMARY_WIDTH"x0,"$SCALING_FACTOR"
      ;;
    top)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x"$SECONDARY_HEIGHT",1
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x0,"$SCALING_FACTOR"
      ;;
    bottom)
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$PRIMARY_MONITOR",preferred,0x0,1
      ${pkgs.hyprland}/bin/hyprctl keyword monitor "$SECONDARY_MONITOR",preferred,0x"$PRIMARY_HEIGHT","$SCALING_FACTOR"
      ;;
    *)
      echo "Invalid option!"
      exit 1
      ;;
  esac
''

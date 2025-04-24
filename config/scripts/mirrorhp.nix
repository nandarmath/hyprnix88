{ pkgs ? import <nixpkgs> {} }:

pkgs.writeScriptBin "adb-scrcpy" ''
ROFI_PATH="$(which rofi)"
ADB_PATH="$(which adb)"
SCRCPY_PATH="$(which scrcpy)"
TERMINAL_PATH="$(which kitty || which alacritty || which gnome-terminal || which xfce4-terminal || which konsole || which xterm)"
TERMINAL_NAME="$(basename $TERMINAL_PATH)"

# Dapatkan IP address melalui Rofi
ip_address=$($ROFI_PATH -dmenu -p "IP Android (contoh: 192.168.1.9:5555)" -lines 0)

# Jika pengguna membatalkan, keluar dari script
if [ -z "$ip_address" ]; then
    exit 0
fi

# Set parameter terminal berdasarkan nama terminal
case $TERMINAL_NAME in
    kitty)
        terminal_cmd="$TERMINAL_PATH"
        ;;
    alacritty)
        terminal_cmd="$TERMINAL_PATH -e"
        ;;
    gnome-terminal)
        terminal_cmd="$TERMINAL_PATH --"
        ;;
    xfce4-terminal)
        terminal_cmd="$TERMINAL_PATH -e"
        ;;
    konsole)
        terminal_cmd="$TERMINAL_PATH -e"
        ;;
    *)
        terminal_cmd="$TERMINAL_PATH -e"
        ;;
esac

# Jalankan perintah dalam terminal
$terminal_cmd bash -c "echo 'Menghubungkan ke $ip_address...' && \
                      $ADB_PATH connect $ip_address && \
                      echo 'Menunggu koneksi...' && \
                      sleep 2 && \
                      echo 'Menjalankan scrcpy...' && \
                      $SCRCPY_PATH --tcpip=$ip_address; \
                      echo -e '\nTekan Enter untuk menutup...'; read"
''

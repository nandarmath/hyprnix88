#!/usr/bin/env bash

# Script untuk mengatur tampilan hyprpanel berdasarkan status window aktif
# Simpan sebagai ~/.config/hypr/scripts/panel-toggle.sh

# Path ke soket Hyprland
HYPR_SOCKET=$(hyprctl socket | head -1)

# Variabel untuk melacak status dashboard
DASHBOARD_VISIBLE=0
BAR_VISIBLE=0

# Fungsi untuk memeriksa apakah ada window aktif
check_active_windows() {
  local workspace_windows=$(hyprctl clients | grep -c "mapped: 1")
  if [ "$workspace_windows" -eq 0 ]; then
    return 0  # Tidak ada window aktif (desktop kosong)
  else
    return 1  # Ada window aktif
  fi
}

# Fungsi untuk menampilkan mode dashboard
show_dashboard_mode() {
  if [ $DASHBOARD_VISIBLE -eq 0 ]; then
    # Sembunyikan bar jika sedang tampil
    if [ $BAR_VISIBLE -eq 1 ]; then
      hyprpanel toggleWindow bar-0
      BAR_VISIBLE=0
    fi
    
    # Tampilkan dashboard
    hyprpanel t dashboardmenu
    
    # Modifikasi properti dashboard agar tidak hilang saat diklik
    DASHBOARD_PID=$(pgrep -f "hyprpanel.*dashboardmenu" | head -1)
    if [ -n "$DASHBOARD_PID" ]; then
      # Gunakan hyprctl untuk mengubah properti window dashboard
      DASHBOARD_ADDR=$(hyprctl clients | grep -A 15 "dashboardmenu" | grep "address: " | head -1 | awk '{print $2}')
      if [ -n "$DASHBOARD_ADDR" ]; then
        hyprctl dispatch focuswindow address:$DASHBOARD_ADDR
        hyprctl dispatch pin address:$DASHBOARD_ADDR
        hyprctl dispatch setkeystate mouse 1   # Disable mouse clicks on dashboard
        sleep 0.1
        hyprctl dispatch setkeystate mouse 0   # Re-enable mouse
      fi
    fi
    
    DASHBOARD_VISIBLE=1
  fi
}

# Fungsi untuk menampilkan mode bar
show_bar_mode() {
  # Sembunyikan dashboard jika sedang tampil
  if [ $DASHBOARD_VISIBLE -eq 1 ]; then
    # Cari dashboard window dan tutup secara paksa
    DASHBOARD_ADDR=$(hyprctl clients | grep -A 15 "dashboardmenu" | grep "address: " | head -1 | awk '{print $2}')
    if [ -n "$DASHBOARD_ADDR" ]; then
      hyprctl dispatch closewindow address:$DASHBOARD_ADDR
    else
      # Backup: Coba tutup dengan native command
      hyprpanel t dashboardmenu close
    fi
    
    DASHBOARD_VISIBLE=0
  fi
  
  # Tampilkan bar jika belum tampil
  if [ $BAR_VISIBLE -eq 0 ]; then
    hyprpanel toggleWindow bar-0
    BAR_VISIBLE=1
  fi
}

# Cek status awal saat script dimulai
if check_active_windows; then
  show_dashboard_mode
else
  show_bar_mode
fi

# Pantau perubahan workspace dan window focus
socat -u UNIX-CONNECT:$HYPR_SOCKET - | while read -r line; do
  case "$line" in
    *"openwindow"*|*"closewindow"*|*"workspace"*)
      # Tunggu sebentar untuk memastikan status window sudah update
      sleep 0.1
      
      # Deteksi perubahan window atau workspace
      if check_active_windows; then
        show_dashboard_mode
      else
        show_bar_mode
      fi
      ;;
  esac
done

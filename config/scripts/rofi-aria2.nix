{ pkgs }:

pkgs.writeShellScriptBin "rofi-aria" ''
  # ============================================
  # Aria2 Complete Manager for Hyprland/Wayland
  # ============================================
  # Dependencies: aria2, rofi-wayland, cliphist, jq, libnotify, wl-clipboard
  
  # ============================================
  # KONFIGURASI
  # ============================================
  ARIA2URI="http://localhost:6800/jsonrpc"
  ARIA2TOKEN=""  # Kosongkan jika tidak pakai token
  ROFI="${pkgs.rofi-wayland}/bin/rofi -dmenu -i"
  DOWNLOAD_DIR="$HOME/Downloads"
  TEMP_DIR="/tmp/aria2-manager"
  METALINK_DIR="$HOME/.config/aria2/metalinks"
  
  # Buat direktori jika belum ada
  ${pkgs.coreutils}/bin/mkdir -p "$TEMP_DIR" "$METALINK_DIR"
  
  # ============================================
  # FUNGSI UTILITY
  # ============================================
  
  # Fungsi untuk memanggil aria2 JSON-RPC
  aria2_rpc() {
      local method="$1"
      shift
      local params="$@"
      
      if [[ -z "$ARIA2TOKEN" ]]; then
          data=$(${pkgs.jq}/bin/jq -n --arg method "$method" --argjson params "[$params]" \
              '{"jsonrpc":"2.0","id":"'$(${pkgs.coreutils}/bin/date +%N)'","method":$method,"params":$params}')
      else
          data=$(${pkgs.jq}/bin/jq -n --arg token "$ARIA2TOKEN" --arg method "$method" --argjson params "[$params]" \
              '{"jsonrpc":"2.0","id":"'$(${pkgs.coreutils}/bin/date +%N)'","method":$method,"params":["token:'$token'"] + $params}')
      fi
      
      ${pkgs.curl}/bin/curl -s --request POST --url "$ARIA2URI" \
          --header 'Content-Type: application/json' \
          --data "$data"
  }
  
  # Notifikasi
  notify() {
      ${pkgs.libnotify}/bin/notify-send "Aria2 Manager" "$1" -u "''${2:-normal}" -t "''${3:-3000}"
  }
  
  # Dapatkan URL dari clipboard
  get_clipboard_urls() {
      if command -v ${pkgs.cliphist}/bin/cliphist &> /dev/null; then
          ${pkgs.cliphist}/bin/cliphist list | ${pkgs.gnugrep}/bin/grep -Po '(http|https|ftp|ftps|magnet:).*?(?=\s|$)' | ${pkgs.gawk}/bin/awk '!seen[$0]++'
      else
          ${pkgs.wl-clipboard}/bin/wl-paste 2>/dev/null | ${pkgs.gnugrep}/bin/grep -Po '(http|https|ftp|ftps|magnet:).*?(?=\s|$)'
      fi
  }
  
  # ============================================
  # FITUR 1: ADD DOWNLOAD
  # ============================================
  
  add_download() {
      local type=$(${pkgs.coreutils}/bin/echo -e "URL/HTTP(S)\nMagnet Link\nTorrent File\nMetalink File\nBatch URLs (File)" | $ROFI -p "Download Type")
      
      case "$type" in
          "URL/HTTP(S)")
              add_url
              ;;
          "Magnet Link")
              add_magnet
              ;;
          "Torrent File")
              add_torrent
              ;;
          "Metalink File")
              add_metalink
              ;;
          "Batch URLs (File)")
              add_batch
              ;;
      esac
  }
  
  add_url() {
      local url=$(get_clipboard_urls | $ROFI -p "Select URL")
      [[ -z "$url" ]] && return
      
      # Options
      local opts=$(${pkgs.coreutils}/bin/echo -e "Default\nCustom Directory\nWith Authentication\nWith Options" | $ROFI -p "Download Options")
      
      case "$opts" in
          "Default")
              response=$(aria2_rpc "aria2.addUri" "[\"$url\"]")
              ;;
          "Custom Directory")
              local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Download Directory")
              response=$(aria2_rpc "aria2.addUri" "[\"$url\"], {\"dir\":\"$dir\"}")
              ;;
          "With Authentication")
              local user=$(${pkgs.coreutils}/bin/echo "" | $ROFI -p "Username")
              local pass=$(${pkgs.coreutils}/bin/echo "" | $ROFI -password -p "Password")
              response=$(aria2_rpc "aria2.addUri" "[\"$url\"], {\"http-user\":\"$user\",\"http-passwd\":\"$pass\"}")
              ;;
          "With Options")
              add_url_advanced "$url"
              return
              ;;
      esac
      
      check_response "$response" "URL download added"
  }
  
  add_url_advanced() {
      local url="$1"
      local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Directory")
      local connections=$(${pkgs.coreutils}/bin/echo "16" | $ROFI -p "Max Connections (1-16)")
      local speed=$(${pkgs.coreutils}/bin/echo "" | $ROFI -p "Max Speed (e.g., 1M, leave empty for unlimited)")
      local proxy=$(${pkgs.coreutils}/bin/echo "" | $ROFI -p "Proxy (e.g., http://proxy:8080)")
      
      local options="{\"dir\":\"$dir\",\"max-connection-per-server\":$connections"
      [[ ! -z "$speed" ]] && options+=",\"max-download-limit\":\"$speed\""
      [[ ! -z "$proxy" ]] && options+=",\"all-proxy\":\"$proxy\""
      options+="}"
      
      response=$(aria2_rpc "aria2.addUri" "[\"$url\"], $options")
      check_response "$response" "Advanced URL download added"
  }
  
  add_magnet() {
      local magnet=$(get_clipboard_urls | ${pkgs.gnugrep}/bin/grep "magnet:" | $ROFI -p "Select Magnet Link")
      [[ -z "$magnet" ]] && magnet=$(${pkgs.coreutils}/bin/echo "" | $ROFI -p "Paste Magnet Link")
      [[ -z "$magnet" ]] && return
      
      local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Download Directory")
      local seed=$(${pkgs.coreutils}/bin/echo -e "Yes\nNo" | $ROFI -p "Seed after download?")
      
      local seed_ratio="0.0"
      [[ "$seed" == "Yes" ]] && seed_ratio="1.0"
      
      response=$(aria2_rpc "aria2.addUri" "[\"$magnet\"], {\"dir\":\"$dir\",\"seed-ratio\":$seed_ratio}")
      check_response "$response" "Magnet link added"
  }
  
  add_torrent() {
      local torrent_file=$(${pkgs.findutils}/bin/find ~/Downloads ~/.local/share/qbittorrent ~/.config/aria2 -name "*.torrent" 2>/dev/null | $ROFI -p "Select Torrent File")
      [[ -z "$torrent_file" ]] && return
      
      local torrent_b64=$(${pkgs.coreutils}/bin/base64 -w0 < "$torrent_file")
      local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Download Directory")
      
      response=$(aria2_rpc "aria2.addTorrent" "\"$torrent_b64\", [], {\"dir\":\"$dir\"}")
      check_response "$response" "Torrent added"
  }
  
  add_metalink() {
      local metalink_file=$(${pkgs.findutils}/bin/find "$METALINK_DIR" -name "*.metalink" -o -name "*.meta4" 2>/dev/null | $ROFI -p "Select Metalink")
      [[ -z "$metalink_file" ]] && return
      
      local metalink_b64=$(${pkgs.coreutils}/bin/base64 -w0 < "$metalink_file")
      local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Download Directory")
      
      response=$(aria2_rpc "aria2.addMetalink" "\"$metalink_b64\", {\"dir\":\"$dir\"}")
      check_response "$response" "Metalink added"
  }
  
  add_batch() {
      local batch_file=$(${pkgs.findutils}/bin/find ~/ -maxdepth 3 -name "*.txt" 2>/dev/null | ${pkgs.coreutils}/bin/head -20 | $ROFI -p "Select URL List File")
      [[ -z "$batch_file" ]] && return
      
      local dir=$(${pkgs.coreutils}/bin/echo "$DOWNLOAD_DIR" | $ROFI -p "Download Directory")
      local count=0
      
      while IFS= read -r url; do
          [[ -z "$url" ]] && continue
          [[ "$url" =~ ^# ]] && continue
          aria2_rpc "aria2.addUri" "[\"$url\"], {\"dir\":\"$dir\"}" > /dev/null
          ((count++))
      done < "$batch_file"
      
      notify "$count URLs added from batch file" "normal" 2000
  }
  
  # ============================================
  # FITUR 2: MANAGE DOWNLOADS
  # ============================================
  
  manage_downloads() {
      local action=$(${pkgs.coreutils}/bin/echo -e "Show Active\nShow All\nPause Download\nResume Download\nRemove Download\nPause All\nResume All\nPurge Completed" | $ROFI -p "Manage Downloads")
      
      case "$action" in
          "Show Active")
              show_active
              ;;
          "Show All")
              show_all
              ;;
          "Pause Download")
              pause_download
              ;;
          "Resume Download")
              resume_download
              ;;
          "Remove Download")
              remove_download
              ;;
          "Pause All")
              aria2_rpc "aria2.pauseAll" > /dev/null
              notify "All downloads paused" "low" 2000
              ;;
          "Resume All")
              aria2_rpc "aria2.unpauseAll" > /dev/null
              notify "All downloads resumed" "low" 2000
              ;;
          "Purge Completed")
              aria2_rpc "aria2.purgeDownloadResult" > /dev/null
              notify "Completed downloads purged" "low" 2000
              ;;
      esac
  }
  
  show_active() {
      local response=$(aria2_rpc "aria2.tellActive" '["gid","status","totalLength","completedLength","downloadSpeed","files"]')
      local downloads=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.result[] | "\(.gid) | \(.files[0].path | split("/")[-1]) | \(.status) | \((.completedLength | tonumber) * 100 / (.totalLength | tonumber + 1) | floor)% | \(.downloadSpeed | tonumber / 1024 / 1024 | floor)MB/s"')
      
      if [[ -z "$downloads" ]]; then
          notify "No active downloads" "low" 2000
          return
      fi
      
      ${pkgs.coreutils}/bin/echo "$downloads" | ${pkgs.util-linux}/bin/column -t -s '|' | $ROFI -p "Active Downloads" -no-custom
  }
  
  show_all() {
      local active=$(aria2_rpc "aria2.tellActive" '["gid","status","files","completedLength","totalLength"]')
      local waiting=$(aria2_rpc "aria2.tellWaiting" '0, 100, ["gid","status","files"]')
      local stopped=$(aria2_rpc "aria2.tellStopped" '0, 100, ["gid","status","files"]')
      
      local all_downloads=$(
          ${pkgs.coreutils}/bin/echo "$active" | ${pkgs.jq}/bin/jq -r '.result[] | "▶ \(.gid) | \(.files[0].path | split("/")[-1]) | \(.status)"'
          ${pkgs.coreutils}/bin/echo "$waiting" | ${pkgs.jq}/bin/jq -r '.result[] | "⏸ \(.gid) | \(.files[0].path | split("/")[-1]) | \(.status)"'
          ${pkgs.coreutils}/bin/echo "$stopped" | ${pkgs.jq}/bin/jq -r '.result[] | "⏹ \(.gid) | \(.files[0].path | split("/")[-1]) | \(.status)"'
      )
      
      ${pkgs.coreutils}/bin/echo "$all_downloads" | ${pkgs.util-linux}/bin/column -t -s '|' | $ROFI -p "All Downloads" -no-custom
  }
  
  pause_download() {
      local gid=$(get_download_gid "Select download to pause")
      [[ -z "$gid" ]] && return
      
      aria2_rpc "aria2.pause" "\"$gid\"" > /dev/null
      notify "Download paused (GID: $gid)" "low" 2000
  }
  
  resume_download() {
      local gid=$(get_paused_gid "Select download to resume")
      [[ -z "$gid" ]] && return
      
      aria2_rpc "aria2.unpause" "\"$gid\"" > /dev/null
      notify "Download resumed (GID: $gid)" "low" 2000
  }
  
  remove_download() {
      local gid=$(get_download_gid "Select download to remove")
      [[ -z "$gid" ]] && return
      
      local force=$(${pkgs.coreutils}/bin/echo -e "Normal Remove\nForce Remove" | $ROFI -p "Remove Type")
      
      if [[ "$force" == "Force Remove" ]]; then
          aria2_rpc "aria2.forceRemove" "\"$gid\"" > /dev/null
      else
          aria2_rpc "aria2.remove" "\"$gid\"" > /dev/null
      fi
      
      notify "Download removed (GID: $gid)" "low" 2000
  }
  
  get_download_gid() {
      local response=$(aria2_rpc "aria2.tellActive" '["gid","files"]')
      local gid=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.result[] | "\(.gid) | \(.files[0].path | split("/")[-1])"' | $ROFI -p "$1" | ${pkgs.gawk}/bin/awk '{print $1}')
      ${pkgs.coreutils}/bin/echo "$gid"
  }
  
  get_paused_gid() {
      local response=$(aria2_rpc "aria2.tellWaiting" '0, 100, ["gid","files"]')
      local gid=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.result[] | "\(.gid) | \(.files[0].path | split("/")[-1])"' | $ROFI -p "$1" | ${pkgs.gawk}/bin/awk '{print $1}')
      ${pkgs.coreutils}/bin/echo "$gid"
  }
  
  # ============================================
  # FITUR 3: ADVANCED OPTIONS
  # ============================================
  
  advanced_options() {
      local option=$(${pkgs.coreutils}/bin/echo -e "Change Global Speed Limit\nChange Connections Per Server\nChange Max Concurrent Downloads\nEnable/Disable Proxy\nView Statistics\nClean Up Downloads\nExport Session" | $ROFI -p "Advanced Options")
      
      case "$option" in
          "Change Global Speed Limit")
              change_speed_limit
              ;;
          "Change Connections Per Server")
              change_connections
              ;;
          "Change Max Concurrent Downloads")
              change_max_downloads
              ;;
          "Enable/Disable Proxy")
              configure_proxy
              ;;
          "View Statistics")
              view_statistics
              ;;
          "Clean Up Downloads")
              cleanup_downloads
              ;;
          "Export Session")
              export_session
              ;;
      esac
  }
  
  change_speed_limit() {
      local type=$(${pkgs.coreutils}/bin/echo -e "Download Limit\nUpload Limit" | $ROFI -p "Limit Type")
      local speed=$(${pkgs.coreutils}/bin/echo "1M" | $ROFI -p "Speed Limit (e.g., 1M, 500K, 0=unlimited)")
      
      if [[ "$type" == "Download Limit" ]]; then
          aria2_rpc "aria2.changeGlobalOption" "{\"max-overall-download-limit\":\"$speed\"}" > /dev/null
          notify "Download limit set to $speed" "low" 2000
      else
          aria2_rpc "aria2.changeGlobalOption" "{\"max-overall-upload-limit\":\"$speed\"}" > /dev/null
          notify "Upload limit set to $speed" "low" 2000
      fi
  }
  
  change_connections() {
      local conn=$(${pkgs.coreutils}/bin/echo "16" | $ROFI -p "Max Connections Per Server (1-16)")
      aria2_rpc "aria2.changeGlobalOption" "{\"max-connection-per-server\":\"$conn\"}" > /dev/null
      notify "Max connections set to $conn" "low" 2000
  }
  
  change_max_downloads() {
      local max=$(${pkgs.coreutils}/bin/echo "5" | $ROFI -p "Max Concurrent Downloads")
      aria2_rpc "aria2.changeGlobalOption" "{\"max-concurrent-downloads\":\"$max\"}" > /dev/null
      notify "Max concurrent downloads set to $max" "low" 2000
  }
  
  configure_proxy() {
      local action=$(${pkgs.coreutils}/bin/echo -e "Enable Proxy\nDisable Proxy" | $ROFI -p "Proxy Action")
      
      if [[ "$action" == "Enable Proxy" ]]; then
          local proxy=$(${pkgs.coreutils}/bin/echo "http://127.0.0.1:8080" | $ROFI -p "Proxy URL")
          aria2_rpc "aria2.changeGlobalOption" "{\"all-proxy\":\"$proxy\"}" > /dev/null
          notify "Proxy enabled: $proxy" "low" 2000
      else
          aria2_rpc "aria2.changeGlobalOption" "{\"all-proxy\":\"\"}" > /dev/null
          notify "Proxy disabled" "low" 2000
      fi
  }
  
  view_statistics() {
      local stats=$(aria2_rpc "aria2.getGlobalStat" "")
      local info=$(${pkgs.coreutils}/bin/echo "$stats" | ${pkgs.jq}/bin/jq -r '.result | "Active: \(.numActive)\nWaiting: \(.numWaiting)\nStopped: \(.numStopped)\nDownload Speed: \((.downloadSpeed | tonumber) / 1024 / 1024 | floor)MB/s\nUpload Speed: \((.uploadSpeed | tonumber) / 1024 / 1024 | floor)MB/s"')
      
      ${pkgs.coreutils}/bin/echo "$info" | $ROFI -p "Aria2 Statistics" -no-custom
  }
  
  cleanup_downloads() {
      aria2_rpc "aria2.purgeDownloadResult" > /dev/null
      local response=$(aria2_rpc "aria2.tellStopped" '0, 1000, ["gid","status"]')
      local stopped=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.result[] | select(.status == "error" or .status == "removed") | .gid')
      
      while IFS= read -r gid; do
          aria2_rpc "aria2.removeDownloadResult" "\"$gid\"" > /dev/null
      done <<< "$stopped"
      
      notify "Downloads cleaned up" "low" 2000
  }
  
  export_session() {
      aria2_rpc "aria2.saveSession" > /dev/null
      notify "Session saved to aria2.session" "low" 2000
  }
  
  # ============================================
  # UTILITY FUNCTIONS
  # ============================================
  
  check_response() {
      local response="$1"
      local message="$2"
      
      if ${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -e '.result' &> /dev/null; then
          local gid=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.result')
          notify "$message (GID: $gid)" "low" 2000
      else
          local error=$(${pkgs.coreutils}/bin/echo "$response" | ${pkgs.jq}/bin/jq -r '.error.message // "Unknown error"')
          notify "Error: $error" "critical" 5000
      fi
  }
  
  # ============================================
  # MAIN MENU
  # ============================================
  
  main_menu() {
      local choice=$(${pkgs.coreutils}/bin/echo -e "➕ Add Download\n📋 Manage Downloads\n⚙️  Advanced Options\n📊 View Statistics\n🔄 Refresh Aria2\n❌ Exit" | $ROFI -p "Aria2 Manager")
      
      case "$choice" in
          "➕ Add Download")
              add_download
              main_menu
              ;;
          "📋 Manage Downloads")
              manage_downloads
              main_menu
              ;;
          "⚙️  Advanced Options")
              advanced_options
              main_menu
              ;;
          "📊 View Statistics")
              view_statistics
              main_menu
              ;;
          "🔄 Refresh Aria2")
              notify "Reloading aria2 daemon..." "low" 2000
              ${pkgs.procps}/bin/pkill aria2c 2>/dev/null
              ${pkgs.coreutils}/bin/sleep 1
              ${pkgs.aria2}/bin/aria2c --enable-rpc --rpc-listen-all=false --rpc-listen-port=6800 -D
              notify "Aria2 restarted" "low" 2000
              main_menu
              ;;
          "❌ Exit")
              exit 0
              ;;
          *)
              [[ -z "$choice" ]] && exit 0
              main_menu
              ;;
      esac
  }
  
  # ============================================
  # START
  # ============================================
  
  main_menu
''

#!/bin/bash
# ============================================
# YouTube Search & Watch with MPV
# ============================================
# Dependencies: mpv, yt-dlp, rofi, libnotify, jq, wl-clipboard/xclip
# Author: YouTube Watch Script
# License: MIT

# ============================================
# KONFIGURASI
# ============================================
MPV="mpv"
YT_DLP="yt-dlp"
HISTORY_FILE="$HOME/.cache/yt-watch/history"
CACHE_DIR="$HOME/.cache/yt-watch"

# Fungsi rofi dengan width 60%
rofi_menu() {
    rofi -dmenu -i -theme-str 'window {width: 60%;}' "$@"
}

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# CEK DEPENDENCIES
# ============================================
check_dependencies() {
    local missing=()
    
    command -v mpv &> /dev/null || missing+=("mpv")
    command -v yt-dlp &> /dev/null || missing+=("yt-dlp")
    command -v rofi &> /dev/null || missing+=("rofi")
    command -v jq &> /dev/null || missing+=("jq")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}Install dengan:${NC}"
        echo "  sudo pacman -S ${missing[*]}"
        echo "  # atau"
        echo "  sudo apt install ${missing[*]}"
        exit 1
    fi
}

# ============================================
# SETUP
# ============================================
setup() {
    mkdir -p "$CACHE_DIR"
    touch "$HISTORY_FILE"
}

# ============================================
# FUNGSI UTILITY
# ============================================

notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "YouTube Watch" "$1" -u "${2:-normal}" -t "${3:-3000}"
    fi
    echo -e "${BLUE}[INFO]${NC} $1"
}

error_msg() {
    if command -v notify-send &> /dev/null; then
        notify-send "YouTube Watch" "$1" -u critical -t 5000
    fi
    echo -e "${RED}[ERROR]${NC} $1"
}

success_msg() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Fungsi untuk search YouTube menggunakan yt-dlp dengan info lengkap
format_search_results() {
    local query="$1"
    local max_results="${2:-20}"
    
    notify "Searching YouTube: $query" "normal" 2000
    
    # Search menggunakan yt-dlp dengan format JSON lengkap
    $YT_DLP "ytsearch${max_results}:$query" \
        --flat-playlist \
        --skip-download \
        --dump-json 2>/dev/null | \
        jq -r '"\(.id)|\(.title)|\(.duration_string // "LIVE")|\(.upload_date // "null")"' 2>/dev/null
}

# Ambil URL dari video ID
get_video_url() {
    local video_id="$1"
    echo "https://www.youtube.com/watch?v=$video_id"
}

# Simpan ke history
save_to_history() {
    local video_id="$1"
    local title="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp|$video_id|$title" >> "$HISTORY_FILE"
}

# Get clipboard content
get_clipboard() {
    if command -v wl-paste &> /dev/null; then
        wl-paste 2>/dev/null
    elif command -v xclip &> /dev/null; then
        xclip -selection clipboard -o 2>/dev/null
    else
        echo ""
    fi
}

# ============================================
# FITUR UTAMA
# ============================================

# Mode: Search & Watch
search_and_watch() {
    # Input search query
    local query=$(echo "" | rofi_menu -p "🔍 Search YouTube")
    [[ -z "$query" ]] && return
    
    notify "Searching: $query" "normal" 2000
    
    # Search dan format hasil
    local results=$(format_search_results "$query")
    
    if [[ -z "$results" ]]; then
        error_msg "No results found for: $query"
        return
    fi
    
    # Tampilkan hasil di rofi dengan format: Durasi | Tanggal Upload | Judul
    local selection=$(echo "$results" | \
        awk -F'|' '{
            duration = $3
            upload_date = $4
            title = $2
            
            # Format tanggal
            if (upload_date == "null" || upload_date == "") {
                formatted_date = "Unknown   "
            } else {
                year = substr(upload_date, 1, 4)
                month = substr(upload_date, 5, 2)
                day = substr(upload_date, 7, 2)
                formatted_date = day "/" month "/" year
            }
            
            printf "%-10s | %-12s | %s\n", duration, formatted_date, title
        }' | \
        rofi_menu -p "📺 Select Video" -format "i" -mesg "Durasi | Tanggal Upload | Judul")
    
    [[ -z "$selection" ]] && return
    
    # Ambil video ID dari baris yang dipilih (index dimulai dari 0)
    local video_id=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f1)
    local title=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f2)
    
    if [[ -z "$video_id" ]]; then
        error_msg "Failed to get video ID"
        return
    fi
    
    select_quality_and_play "$video_id" "$title"
}

# Mode: Watch from URL/clipboard
watch_from_clipboard() {
    local url
    
    # Coba ambil dari clipboard
    url=$(get_clipboard | grep -Eo 'https?://[^\s]+' | grep -i 'youtube\|youtu.be' | head -1)
    
    # Jika tidak ada di clipboard, tanya user
    if [[ -z "$url" ]]; then
        url=$(echo "" | rofi_menu -p "📺 YouTube URL")
    fi
    
    [[ -z "$url" ]] && return
    
    notify "Getting video info..." "normal" 2000
    
    # Ambil info video
    local video_info=$($YT_DLP "$url" --dump-json 2>/dev/null | jq -r '"\(.id)|\(.title)"' | head -1)
    
    if [[ -z "$video_info" ]]; then
        error_msg "Failed to get video info"
        return
    fi
    
    local video_id=$(echo "$video_info" | cut -d'|' -f1)
    local title=$(echo "$video_info" | cut -d'|' -f2)
    
    select_quality_and_play "$video_id" "$title"
}

# Mode: View History
view_history() {
    if [[ ! -s "$HISTORY_FILE" ]]; then
        notify "No watch history" "normal" 2000
        return
    fi
    
    # Tampilkan history (30 terakhir)
    local selection=$(tail -30 "$HISTORY_FILE" | \
        tac | \
        awk -F'|' '{printf "%-20s | %s\n", $1, $3}' | \
        rofi_menu -p "📜 Watch History" -format "i")
    
    [[ -z "$selection" ]] && return
    
    # Ambil video ID
    local video_id=$(tail -30 "$HISTORY_FILE" | tac | sed -n "$((selection + 1))p" | cut -d'|' -f2)
    local title=$(tail -30 "$HISTORY_FILE" | tac | sed -n "$((selection + 1))p" | cut -d'|' -f3)
    
    select_quality_and_play "$video_id" "$title"
}

# Mode: Trending Videos
watch_trending() {
    notify "Fetching trending videos..." "normal" 2000
    
    local results=$($YT_DLP "https://www.youtube.com/feed/trending" \
        --flat-playlist \
        --playlist-end 20 \
        --dump-json 2>/dev/null | \
        jq -r '"\(.id)|\(.title)|\(.duration_string // "LIVE")|\(.upload_date // "null")"')
    
    if [[ -z "$results" ]]; then
        error_msg "Failed to fetch trending videos"
        return
    fi
    
    local selection=$(echo "$results" | \
        awk -F'|' '{
            duration = $3
            upload_date = $4
            title = $2
            
            # Format tanggal
            if (upload_date == "null" || upload_date == "") {
                formatted_date = "Unknown   "
            } else {
                year = substr(upload_date, 1, 4)
                month = substr(upload_date, 5, 2)
                day = substr(upload_date, 7, 2)
                formatted_date = day "/" month "/" year
            }
            
            printf "%-10s | %-12s | %s\n", duration, formatted_date, title
        }' | \
        rofi_menu -p "🔥 Trending Videos" -format "i" -mesg "Durasi | Tanggal Upload | Judul")
    
    [[ -z "$selection" ]] && return
    
    local video_id=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f1)
    local title=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f2)
    
    select_quality_and_play "$video_id" "$title"
}

# Pilih kualitas dan play
select_quality_and_play() {
    local video_id="$1"
    local title="$2"
    local url=$(get_video_url "$video_id")
    
    # Pilihan kualitas dengan emoji
    local quality=$(echo -e "🎬 Best (Auto)\n📺 1080p\n📺 720p\n📱 480p\n📱 360p\n🎵 Audio Only" | \
        rofi_menu -p "🎥 Select Quality" | cut -d' ' -f2-)
    
    case "$quality" in
        "Best (Auto)")
            play_video "$url" "$title" "bestvideo+bestaudio/best"
            ;;
        "1080p")
            play_video "$url" "$title" "bestvideo[height<=1080]+bestaudio/best[height<=1080]"
            ;;
        "720p")
            play_video "$url" "$title" "bestvideo[height<=720]+bestaudio/best[height<=720]"
            ;;
        "480p")
            play_video "$url" "$title" "bestvideo[height<=480]+bestaudio/best[height<=480]"
            ;;
        "360p")
            play_video "$url" "$title" "bestvideo[height<=360]+bestaudio/best[height<=360]"
            ;;
        "Audio Only")
            play_video "$url" "$title" "bestaudio/best"
            ;;
        *)
            return
            ;;
    esac
}

# Play video dengan MPV
play_video() {
    local url="$1"
    local title="$2"
    local format="$3"
    
    success_msg "Loading: $title"
    notify "▶️ Playing: $title" "normal" 2000
    
    # Save to history
    local video_id=$(echo "$url" | grep -oP '(?<=v=)[^&]+')
    save_to_history "$video_id" "$title"
    
    # Play dengan MPV
    $MPV \
        --ytdl-format="$format" \
        --title="$title" \
        --force-window=immediate \
        --keep-open=yes \
        --ytdl-raw-options=cookies-from-browser=firefox \
        "$url" 2>/dev/null
    
    success_msg "Finished playing: $title"
}

# Mode: Download Video
download_video() {
    local query=$(echo "" | rofi_menu -p "🔍 Search to Download")
    [[ -z "$query" ]] && return
    
    notify "Searching: $query" "normal" 2000
    
    local results=$(format_search_results "$query")
    
    if [[ -z "$results" ]]; then
        error_msg "No results found"
        return
    fi
    
    local selection=$(echo "$results" | \
        awk -F'|' '{
            duration = $3
            upload_date = $4
            title = $2
            
            if (upload_date == "null" || upload_date == "") {
                formatted_date = "Unknown   "
            } else {
                year = substr(upload_date, 1, 4)
                month = substr(upload_date, 5, 2)
                day = substr(upload_date, 7, 2)
                formatted_date = day "/" month "/" year
            }
            
            printf "%-10s | %-12s | %s\n", duration, formatted_date, title
        }' | \
        rofi_menu -p "⬇️ Select to Download" -format "i" -mesg "Durasi | Tanggal Upload | Judul")
    
    [[ -z "$selection" ]] && return
    
    local video_id=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f1)
    local title=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f2)
    local url=$(get_video_url "$video_id")
    
    # Pilih format download
    local format=$(echo -e "🎬 Best Video+Audio (MP4)\n📺 1080p (MP4)\n📺 720p (MP4)\n🎵 Audio (MP3)\n🎵 Audio (M4A)" | \
        rofi_menu -p "📥 Download Format" | cut -d' ' -f2-)
    
    local output_dir="$HOME/Videos/YouTube"
    mkdir -p "$output_dir"
    
    case "$format" in
        "Best Video+Audio (MP4)")
            notify "⬇️ Downloading: $title" "normal" 3000
            $YT_DLP -f "bestvideo+bestaudio" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$url" &
            ;;
        "1080p (MP4)")
            notify "⬇️ Downloading 1080p: $title" "normal" 3000
            $YT_DLP -f "bestvideo[height<=1080]+bestaudio" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$url" &
            ;;
        "720p (MP4)")
            notify "⬇️ Downloading 720p: $title" "normal" 3000
            $YT_DLP -f "bestvideo[height<=720]+bestaudio" --merge-output-format mp4 -o "$output_dir/%(title)s.%(ext)s" "$url" &
            ;;
        "Audio (MP3)")
            notify "⬇️ Downloading audio (MP3): $title" "normal" 3000
            $YT_DLP -x --audio-format mp3 -o "$output_dir/%(title)s.%(ext)s" "$url" &
            ;;
        "Audio (M4A)")
            notify "⬇️ Downloading audio (M4A): $title" "normal" 3000
            $YT_DLP -x --audio-format m4a -o "$output_dir/%(title)s.%(ext)s" "$url" &
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        success_msg "Download started: $title"
        notify "✅ Download started in background" "normal" 2000
    fi
}

# Mode: Quick Play (tanpa menu)
quick_play() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        error_msg "No search query provided"
        return 1
    fi
    
    echo -e "${YELLOW}Searching for:${NC} $query"
    
    local results=$(format_search_results "$query" 10)
    
    if [[ -z "$results" ]]; then
        error_msg "No results found for: $query"
        return 1
    fi
    
    # Tampilkan hasil
    local selection=$(echo "$results" | \
        awk -F'|' '{
            duration = $3
            upload_date = $4
            title = $2
            
            if (upload_date == "null" || upload_date == "") {
                formatted_date = "Unknown   "
            } else {
                year = substr(upload_date, 1, 4)
                month = substr(upload_date, 5, 2)
                day = substr(upload_date, 7, 2)
                formatted_date = day "/" month "/" year
            }
            
            printf "%-10s | %-12s | %s\n", duration, formatted_date, title
        }' | \
        rofi_menu -p "📺 Select Video" -format "i" -mesg "Durasi | Tanggal Upload | Judul")
    
    [[ -z "$selection" ]] && return
    
    local video_id=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f1)
    local title=$(echo "$results" | sed -n "$((selection + 1))p" | cut -d'|' -f2)
    
    select_quality_and_play "$video_id" "$title"
}

# ============================================
# MAIN MENU
# ============================================

main_menu() {
    local choice=$(echo -e "🔍 Search & Watch\n📺 Watch from URL\n📜 Watch History\n🔥 Trending Videos\n⬇️  Download Video\n🗑️  Clear History\n❌ Exit" | \
        rofi_menu -p "🎬 YouTube Watch" -mesg "Select an option")
    
    case "$choice" in
        "🔍 Search & Watch")
            search_and_watch
            main_menu
            ;;
        "📺 Watch from URL")
            watch_from_clipboard
            main_menu
            ;;
        "📜 Watch History")
            view_history
            main_menu
            ;;
        "🔥 Trending Videos")
            watch_trending
            main_menu
            ;;
        "⬇️  Download Video")
            download_video
            main_menu
            ;;
        "🗑️  Clear History")
            if [[ -f "$HISTORY_FILE" ]]; then
                > "$HISTORY_FILE"
                notify "History cleared" "normal" 2000
            fi
            main_menu
            ;;
        "❌ Exit")
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
}

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${GREEN}YouTube Watch Script${NC}
${YELLOW}Usage:${NC}
  $0                    # Show main menu
  $0 [search query]     # Quick search and play
  $0 --url [youtube_url] # Play from URL
  $0 --help             # Show this help

${YELLOW}Examples:${NC}
  $0                           # Open main menu
  $0 "lofi music"              # Search for lofi music
  $0 "linux tutorial"          # Search for linux tutorial
  $0 --url "https://youtube.com/watch?v=..."

${YELLOW}Dependencies:${NC}
  - mpv (video player)
  - yt-dlp (youtube downloader)
  - rofi (menu selector)
  - jq (json parser)
  - notify-send (notifications - optional)
  - wl-clipboard or xclip (clipboard - optional)

${YELLOW}Install:${NC}
  sudo pacman -S mpv yt-dlp rofi jq libnotify wl-clipboard
  # or
  sudo apt install mpv yt-dlp rofi jq libnotify-bin wl-clipboard

${YELLOW}Features:${NC}
  ✅ Search YouTube videos
  ✅ Display duration, upload date, and title
  ✅ Rofi window width 60% of screen
  ✅ Watch from URL/clipboard
  ✅ View watch history
  ✅ Trending videos
  ✅ Download videos (multiple formats)
  ✅ Quality selection (Auto/1080p/720p/480p/360p/Audio)
  ✅ MPV integration

${YELLOW}Keyboard Shortcuts (in MPV):${NC}
  Space     - Pause/Play
  F         - Fullscreen
  ←/→       - Skip 5 seconds
  ↑/↓       - Volume
  Q         - Quit
  M         - Mute

${YELLOW}Files:${NC}
  History: ~/.cache/yt-watch/history
  Downloads: ~/Videos/YouTube/
EOF
}

# ============================================
# MAIN
# ============================================

main() {
    # Check dependencies
    check_dependencies
    
    # Setup
    setup
    
    # Parse arguments
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --url)
            shift
            url="$1"
            [[ -z "$url" ]] && error_msg "No URL provided" && exit 1
            video_info=$($YT_DLP "$url" --dump-json 2>/dev/null | jq -r '"\(.id)|\(.title)"' | head -1)
            video_id=$(echo "$video_info" | cut -d'|' -f1)
            title=$(echo "$video_info" | cut -d'|' -f2)
            select_quality_and_play "$video_id" "$title"
            ;;
        "")
            main_menu
            ;;
        *)
            quick_play "$*"
            ;;
    esac
}

# Run main
main "$@"

#!/usr/bin/env bash
#
# Script name: dm-pipewire-out-switcher
# Description: Switch default output for pipewire (Standalone version)
# Dependencies: rofi, pipewire, jq, pactl
# Modified to be standalone without dm-helper dependency

set -euo pipefail

# Fungsi untuk mengirim notifikasi
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    
    if command -v notify-send &> /dev/null; then
        notify-send -u "$urgency" "$title" "$message"
    elif command -v dunstify &> /dev/null; then
        dunstify -u "$urgency" "$title" "$message"
    else
        echo "$title: $message"
    fi
}

# Fungsi untuk check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in rofi pactl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check if pipewire is running
    if ! pgrep -x pipewire &> /dev/null && ! pgrep -x pulseaudio &> /dev/null; then
        send_notification "Error" "PipeWire atau PulseAudio tidak berjalan!" "critical"
        echo "Error: PipeWire or PulseAudio is not running" >&2
        exit 1
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(IFS=', '; echo "${missing_deps[*]}")
        send_notification "Error - Missing Dependencies" "Dependencies tidak ditemukan: $deps_list" "critical"
        echo "Error: Missing dependencies: $deps_list" >&2
        echo "Please install: rofi, pipewire (or pulseaudio), jq" >&2
        exit 1
    fi
}

# Fungsi untuk mendapatkan default sink
get_default_sink() {
    pactl --format=json info 2>/dev/null | jq -r '.default_sink_name // empty'
}

# Fungsi untuk mendapatkan semua sinks dengan info lebih detail
get_all_sinks() {
    local current_sink
    current_sink=$(get_default_sink)
    
    pactl --format=json list sinks 2>/dev/null | jq -r --arg current "$current_sink" '
        .[] | 
        if .name == $current then 
            "✓ " + .description + " [" + .name + "]"
        else 
            "  " + .description + " [" + .name + "]"
        end
    '
}

# Fungsi untuk extract sink name dari pilihan
extract_sink_name() {
    local choice="$1"
    # Extract text between [ and ]
    echo "$choice" | grep -oP '\[\K[^\]]+' || echo ""
}

# Fungsi untuk mendapatkan volume sink
get_sink_volume() {
    local sink_name="$1"
    pactl --format=json list sinks 2>/dev/null | jq -r --arg sink "$sink_name" '
        .[] | select(.name == $sink) | 
        .volume.front_left.value_percent // "0%"
    ' | tr -d '%'
}

# Fungsi untuk set volume
set_sink_volume() {
    local sink_name="$1"
    local volume="$2"
    pactl set-sink-volume "$sink_name" "${volume}%"
}

# Fungsi untuk toggle mute
toggle_sink_mute() {
    local sink_name="$1"
    pactl set-sink-mute "$sink_name" toggle
    
    local is_muted
    is_muted=$(pactl --format=json list sinks 2>/dev/null | jq -r --arg sink "$sink_name" '
        .[] | select(.name == $sink) | .mute
    ')
    
    if [ "$is_muted" = "true" ]; then
        send_notification "Audio" "🔇 Muted: $sink_name"
    else
        send_notification "Audio" "🔊 Unmuted: $sink_name"
    fi
}

# Fungsi untuk menampilkan info detail sink
show_sink_info() {
    local sink_name="$1"
    local info
    info=$(pactl --format=json list sinks 2>/dev/null | jq -r --arg sink "$sink_name" '
        .[] | select(.name == $sink) | 
        "Name: " + .name + "\n" +
        "Description: " + .description + "\n" +
        "Driver: " + .driver + "\n" +
        "Sample Rate: " + (.sample_spec.rate | tostring) + " Hz\n" +
        "Channels: " + (.sample_spec.channels | tostring) + "\n" +
        "Volume: " + .volume.front_left.value_percent + "\n" +
        "Muted: " + (.mute | tostring) + "\n" +
        "State: " + .state
    ')
    
    echo "$info" | rofi -dmenu -p "Sink Info" -mesg "Press Esc to close" -theme-str 'window {width: 600px;}'
}

# Fungsi utama
main() {
    check_dependencies
    
    # Get current default sink
    local current_sink
    current_sink=$(get_default_sink)
    
    if [ -z "$current_sink" ]; then
        send_notification "Error" "Tidak ada audio sink yang ditemukan!" "critical"
        exit 1
    fi
    
    # Get all sinks
    local sinks
    sinks=$(get_all_sinks)
    
    if [ -z "$sinks" ]; then
        send_notification "Error" "Tidak ada audio output yang tersedia!" "critical"
        exit 1
    fi
    
    # Show menu with rofi
    local choice
    choice=$(echo "$sinks" | rofi -dmenu -i -p "Select Audio Output:" \
        -mesg "Current: $(pactl --format=json list sinks | jq -r --arg sink "$current_sink" '.[] | select(.name == $sink) | .description')" \
        -theme-str 'window {width: 600px;}')
    
    # Exit if no choice
    if [ -z "$choice" ]; then
        exit 0
    fi
    
    # Extract sink name from choice
    local selected_sink
    selected_sink=$(extract_sink_name "$choice")
    
    if [ -z "$selected_sink" ]; then
        send_notification "Error" "Gagal mengekstrak nama sink!" "critical"
        exit 1
    fi
    
    # Check if same as current
    if [ "$selected_sink" = "$current_sink" ]; then
        # Show additional options for current sink
        local action
        action=$(echo -e "🔊 Volume Control\n🔇 Toggle Mute\nℹ️  Show Info\n← Back" | \
            rofi -dmenu -i -p "Current Sink Options:")
        
        case "$action" in
            "🔊 Volume Control")
                local current_volume
                current_volume=$(get_sink_volume "$selected_sink")
                local new_volume
                new_volume=$(echo "$current_volume" | rofi -dmenu -p "Set Volume (0-150):")
                
                if [[ "$new_volume" =~ ^[0-9]+$ ]] && [ "$new_volume" -ge 0 ] && [ "$new_volume" -le 150 ]; then
                    set_sink_volume "$selected_sink" "$new_volume"
                    send_notification "Audio" "Volume set to ${new_volume}%"
                fi
                ;;
            "🔇 Toggle Mute")
                toggle_sink_mute "$selected_sink"
                ;;
            "ℹ️  Show Info")
                show_sink_info "$selected_sink"
                ;;
        esac
        exit 0
    fi
    
    # Set new default sink
    if pactl set-default-sink "$selected_sink" 2>/dev/null; then
        local sink_description
        sink_description=$(pactl --format=json list sinks 2>/dev/null | jq -r --arg sink "$selected_sink" '.[] | select(.name == $sink) | .description')
        send_notification "Audio Output Switched" "🔊 Now using: $sink_description"
        
        # Move all existing streams to new sink
        pactl --format=json list sink-inputs 2>/dev/null | jq -r '.[].index' | while read -r stream; do
            pactl move-sink-input "$stream" "$selected_sink" 2>/dev/null || true
        done
    else
        send_notification "Error" "Gagal mengubah audio output!" "critical"
        exit 1
    fi
}

# Fungsi help
show_help() {
    cat << EOF
dm-pipewire-out-switcher - Switch PipeWire/PulseAudio output

Usage: $(basename "$0") [OPTIONS]

Options:
    -h, --help       Show this help message
    -l, --list       List all available sinks
    -i, --info       Show info about current sink
    
Dependencies:
    - rofi
    - pipewire or pulseaudio
    - pactl (from pipewire or pulseaudio-utils)
    - jq

Features:
    - Switch between audio outputs
    - Volume control for current sink
    - Toggle mute/unmute
    - Show detailed sink information
    - Automatically move existing streams to new sink

Examples:
    $(basename "$0")              # Show audio output selector
    $(basename "$0") -l           # List all available sinks
    $(basename "$0") -i           # Show current sink info

EOF
}

# List all sinks
list_sinks() {
    check_dependencies
    echo "Available Audio Sinks:"
    echo "===================="
    pactl --format=json list sinks 2>/dev/null | jq -r '.[] | 
        "Name: " + .name + "\n" +
        "Description: " + .description + "\n" +
        "State: " + .state + "\n" +
        "Default: " + (if .name == (pactl --format=json info | jq -r .default_sink_name) then "Yes" else "No" end) + "\n"
    '
}

# Show current sink info
show_current_info() {
    check_dependencies
    local current_sink
    current_sink=$(get_default_sink)
    echo "Current Default Sink:"
    echo "===================="
    show_sink_info "$current_sink"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -l|--list)
        list_sinks
        exit 0
        ;;
    -i|--info)
        show_current_info
        exit 0
        ;;
    "")
        # No arguments, run main
        ;;
    *)
        echo "Error: Unknown option '$1'" >&2
        echo "Use -h for help" >&2
        exit 1
        ;;
esac

# Run main function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main

#!/usr/bin/env bash
#
# Script name: dm-weather
# Description: Simple graphical weather app (Standalone version)
# Dependencies: rofi, curl, yad (atau zenity sebagai alternatif)
# Modified to be standalone without dm-helper dependency

set -euo pipefail

# Configuration - Tambahkan lokasi favorit Anda di sini
weather_locations=(
    "Sleman"
    "Buol"
    "Palu"
    "Yogyakarta"
    "Bali"
    "Singapore"
    "Tokyo"
    "London"
    "New York"
    "Current Location"
)

# Weather options - Customize tampilan weather
# T = No ANSI sequences (plain text)
# 0 = Current weather only
# 1 = Current + today forecast
# 2 = Current + 2 days forecast
# q = Quiet mode (no extra info)
# F = No "Follow" line
weather_opts="T&F"  # Default options

# Fungsi untuk mengirim notifikasi
send_notification() {
    local title="$1"
    local message="$2"
    
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
    elif command -v dunstify &> /dev/null; then
        dunstify "$title" "$message"
    else
        echo "$title: $message"
    fi
}

# Fungsi untuk check dependencies
check_dependencies() {
    local missing_deps=()
    local display_app=""
    
    # Check rofi dan curl
    for cmd in rofi curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check display app (yad atau zenity)
    if command -v yad &> /dev/null; then
        display_app="yad"
    elif command -v zenity &> /dev/null; then
        display_app="zenity"
    elif command -v xterm &> /dev/null; then
        display_app="xterm"
    else
        missing_deps+=("yad or zenity or xterm")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(IFS=', '; echo "${missing_deps[*]}")
        send_notification "Error - Missing Dependencies" "Dependencies tidak ditemukan: $deps_list"
        echo "Error: Missing dependencies: $deps_list" >&2
        echo "Please install: rofi, curl, and (yad or zenity)" >&2
        exit 1
    fi
    
    echo "$display_app"
}

# Fungsi untuk mendapatkan lokasi saat ini berdasarkan IP
get_current_location() {
    local location
    location=$(curl -s "https://ipinfo.io/city" 2>/dev/null || echo "")
    if [ -z "$location" ]; then
        location=$(curl -s "https://ifconfig.co/city" 2>/dev/null || echo "")
    fi
    echo "${location:-Auto}"
}

# Fungsi untuk menampilkan weather di yad
show_weather_yad() {
    local weather_data="$1"
    local location="$2"
    
    echo "$weather_data" | yad --text-info \
        --title="Weather: $location" \
        --width=800 \
        --height=600 \
        --fontname="Monospace 10" \
        --button="Refresh:0" \
        --button="Close:1"
    
    return $?
}

# Fungsi untuk menampilkan weather di zenity
show_weather_zenity() {
    local weather_data="$1"
    local location="$2"
    
    echo "$weather_data" | zenity --text-info \
        --title="Weather: $location" \
        --width=800 \
        --height=600 \
        --font="Monospace 10"
    
    return $?
}

# Fungsi untuk menampilkan weather di xterm
show_weather_xterm() {
    local weather_data="$1"
    local location="$2"
    
    echo "$weather_data" | xterm -T "Weather: $location" -geometry 120x40 -hold -e "cat; echo; echo 'Press Enter to close...'; read"
    
    return $?
}

# Fungsi utama
main() {
    # Check dependencies and get display app
    local display_app
    display_app=$(check_dependencies)
    
    # Show location menu
    local location
    location="$(printf '%s\n' "${weather_locations[@]}" | rofi -dmenu -i -p "Select location for weather:" -theme-str 'window {width: 400px;}')"
    
    # Exit if no location selected
    if [ -z "$location" ]; then
        echo "No location selected" >&2
        exit 0
    fi
    
    # Handle "Current Location" option
    if [ "$location" = "Current Location" ]; then
        send_notification "Weather" "Detecting your location..."
        location=$(get_current_location)
        if [ -z "$location" ] || [ "$location" = "Auto" ]; then
            send_notification "Weather" "Could not detect location, using automatic detection"
            location=""
        fi
    fi
    
    # Show loading notification
    send_notification "Weather" "Fetching weather data for: ${location:-Auto}..."
    
    # Fetch weather data
    local weather_url
    if [ -z "$location" ]; then
        weather_url="https://wttr.in/?${weather_opts}"
    else
        # URL encode spaces
        weather_url="https://wttr.in/${location// /%20}?${weather_opts}"
    fi
    
    local weather_data
    weather_data=$(curl -s "$weather_url" 2>/dev/null)
    
    # Check if curl was successful
    if [ $? -ne 0 ] || [ -z "$weather_data" ]; then
        send_notification "Error" "Failed to fetch weather data. Check your internet connection."
        exit 1
    fi
    
    # Display weather based on available app
    case "$display_app" in
        yad)
            if show_weather_yad "$weather_data" "$location"; then
                # If user clicked Refresh button (return code 0)
                exec "$0"
            fi
            ;;
        zenity)
            show_weather_zenity "$weather_data" "$location"
            ;;
        xterm)
            show_weather_xterm "$weather_data" "$location"
            ;;
    esac
}

# Fungsi untuk menambahkan lokasi baru
add_location() {
    local new_location
    new_location=$(rofi -dmenu -p "Enter new location:" -theme-str 'window {width: 400px;}')
    
    if [ -n "$new_location" ]; then
        echo "Note: Edit the script to permanently add '$new_location' to the location list"
        weather_locations+=("$new_location")
        main
    fi
}

# Fungsi help
show_help() {
    cat << EOF
dm-weather - Simple graphical weather app

Usage: $(basename "$0") [OPTIONS]

Options:
    -h, --help       Show this help message
    -a, --add        Add a new location temporarily
    
Dependencies:
    - rofi
    - curl
    - yad or zenity or xterm (for display)

Configuration:
    Edit the 'weather_locations' array in the script to add permanent locations.
    Edit 'weather_opts' to customize weather display options.
    
Weather Options:
    T   = Plain text (no colors)
    0   = Current weather only
    1   = Current + today forecast
    2   = Current + 2 days forecast
    q   = Quiet mode
    F   = No follow line

Examples:
    $(basename "$0")              # Show weather
    $(basename "$0") -a           # Add new location temporarily

EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -a|--add)
        add_location
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

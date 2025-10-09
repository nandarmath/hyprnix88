#!/usr/bin/env bash
#
# Script name: dm-dictionary
# Description: Uses the translate package as a dictionary (Standalone version)
# Dependencies: rofi, translate-shell, didyoumean
# Modified to be standalone without dm-helper dependency

set -euo pipefail

# Configuration
TERMINAL="${TERMINAL:-alacritty}"  # Ganti dengan terminal favorit Anda (kitty, st, xterm, etc)

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
    
    for cmd in rofi trans dym; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(IFS=', '; echo "${missing_deps[*]}")
        send_notification "Error - Missing Dependencies" "Dependency tidak ditemukan: $deps_list\n\nInstall:\n- rofi\n- translate-shell (trans)\n- didyoumean (dym)"
        echo "Error: Missing dependencies: $deps_list" >&2
        echo "Please install: rofi, translate-shell, didyoumean" >&2
        exit 1
    fi
    
    # Check terminal
    if ! command -v "$TERMINAL" &> /dev/null; then
        echo "Warning: Terminal '$TERMINAL' tidak ditemukan. Mencoba alternatif..." >&2
        for term in kitty alacritty st xterm gnome-terminal; do
            if command -v "$term" &> /dev/null; then
                TERMINAL="$term"
                echo "Menggunakan terminal: $TERMINAL" >&2
                break
            fi
        done
    fi
}

# Fungsi utama
main() {
    check_dependencies
    
    # Get input word from rofi
    word="$(rofi -dmenu -p "Enter word to lookup:" -theme-str 'window {width: 500px;}')"
    
    # Exit if no word entered
    if [ -z "$word" ]; then
        echo "No word inserted" >&2
        exit 0
    fi
    
    # Check for spelling using didyoumean
    testword="$(dym -c -n=1 "$word" 2>/dev/null || echo "$word")"
    
    if [ "$word" != "$testword" ]; then
        # Get spelling suggestions
        suggestions=$(dym -c "$word" 2>/dev/null || echo "no")
        
        # Ask user if they want to use suggested spelling
        keyword=$(echo -e "$suggestions\nno\nUse original: $word" | rofi -dmenu -i -p "Did you mean? ('$word' might be misspelled)" -theme-str 'window {width: 500px;}')
        
        if [ "$keyword" = "no" ] || [ "$keyword" = "n" ] || [ "$keyword" = "Use original: $word" ] || [ -z "$keyword" ]; then
            keyword="$word"
        fi
    else
        keyword="$word"
    fi
    
    # Check if keyword is still valid
    if [ -z "${keyword}" ]; then
        echo "No word selected" >&2
        exit 0
    fi
    
    # Show definition in terminal
    # Different terminals have different syntax for executing commands
    case "$TERMINAL" in
        kitty)
            $TERMINAL --hold sh -c "trans -v -d '$keyword'; echo; echo 'Press any key to close...'; read -n 1" &
            ;;
        alacritty)
            $TERMINAL --hold -e sh -c "trans -v -d '$keyword'; echo; echo 'Press any key to close...'; read -n 1" &
            ;;
        st|xterm)
            $TERMINAL -e sh -c "trans -v -d '$keyword'; echo; echo 'Press Enter to close...'; read" &
            ;;
        gnome-terminal|xfce4-terminal)
            $TERMINAL -- sh -c "trans -v -d '$keyword'; echo; echo 'Press Enter to close...'; read" &
            ;;
        *)
            $TERMINAL -e sh -c "trans -v -d '$keyword'; echo; echo 'Press Enter to close...'; read" &
            ;;
    esac
}

# Fungsi help
show_help() {
    cat << EOF
dm-dictionary - Dictionary lookup using translate-shell

Usage: $(basename "$0") [OPTIONS]

Options:
    -h    Show this help message
    
Dependencies:
    - rofi
    - translate-shell (trans command)
    - didyoumean (dym command)
    - A terminal emulator

Configuration:
    Set TERMINAL environment variable to use your preferred terminal:
    export TERMINAL="kitty"
    
    Supported terminals: kitty, alacritty, st, xterm, gnome-terminal, xfce4-terminal

Examples:
    $(basename "$0")              # Run with default settings
    TERMINAL=kitty $(basename "$0")   # Use kitty terminal

EOF
}

# Parse command line arguments
if [ $# -gt 0 ]; then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
    esac
fi

# Run main function
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main

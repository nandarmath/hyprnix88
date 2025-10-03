#!/usr/bin/env bash
#
# Script name: dm-kill
# Description: Search for a process to kill (Standalone version)
# Dependencies: rofi, ps
# Modified to be standalone without dm-helper dependency

set -euo pipefail

# Configuration
SHOW_ALL_USERS=false  # Set to true to show processes from all users

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
    
    for cmd in rofi ps; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(IFS=', '; echo "${missing_deps[*]}")
        send_notification "Error - Missing Dependencies" "Dependencies tidak ditemukan: $deps_list" "critical"
        echo "Error: Missing dependencies: $deps_list" >&2
        exit 1
    fi
}

# Fungsi untuk format process list dengan info lengkap
get_process_list() {
    local show_all="$1"
    
    if [ "$show_all" = true ]; then
        # Show all processes from all users
        ps aux --sort=-%mem | \
            awk 'NR>1 {printf "%-8s %6s %5s%% %5s%% %-20s %s\n", $2, $1, $3, $4, substr($11,1,20), $11}' | \
            column -t
    else
        # Show only current user's processes
        ps --user "$USER" -o pid,user,%cpu,%mem,comm,args --sort=-%mem | \
            awk 'NR>1 {printf "%-8s %-8s %5s%% %5s%% %-20s %s\n", $1, $2, $3, $4, substr($5,1,20), $6}' | \
            column -t
    fi
}

# Fungsi untuk extract PID dari pilihan
extract_pid() {
    local choice="$1"
    echo "$choice" | awk '{print $1}'
}

# Fungsi untuk extract process name
extract_process_name() {
    local choice="$1"
    echo "$choice" | awk '{print $5}'
}

# Fungsi untuk mendapatkan detail process
get_process_details() {
    local pid="$1"
    
    if ! ps -p "$pid" &>/dev/null; then
        echo "Process not found or already terminated"
        return 1
    fi
    
    local details
    details=$(ps -p "$pid" -o pid,ppid,user,%cpu,%mem,vsz,rss,tty,stat,start,time,command 2>/dev/null | \
        awk 'NR>1')
    
    echo "$details"
}

# Fungsi untuk kill process
kill_process() {
    local pid="$1"
    local process_name="$2"
    local signal="${3:-15}"  # Default SIGTERM
    
    if ! ps -p "$pid" &>/dev/null; then
        send_notification "Process Kill" "Process (PID: $pid) not found or already terminated" "normal"
        return 1
    fi
    
    if kill "-$signal" "$pid" 2>/dev/null; then
        send_notification "Process Killed" "✓ Successfully killed: $process_name (PID: $pid)" "normal"
        return 0
    else
        send_notification "Process Kill Failed" "✗ Failed to kill: $process_name (PID: $pid)" "critical"
        return 1
    fi
}

# Fungsi untuk show process tree
show_process_tree() {
    local pid="$1"
    
    if command -v pstree &>/dev/null; then
        pstree -p "$pid" | rofi -dmenu -p "Process Tree" -mesg "Press Esc to close" -theme-str 'window {width: 800px;}'
    else
        ps --forest -o pid,ppid,cmd -g "$(ps -o pgid= -p "$pid" | tr -d ' ')" | \
            rofi -dmenu -p "Process Hierarchy" -mesg "Press Esc to close" -theme-str 'window {width: 800px;}'
    fi
}

# Fungsi utama
main() {
    check_dependencies
    
    # Get process list
    local processes
    processes=$(get_process_list "$SHOW_ALL_USERS")
    
    if [ -z "$processes" ]; then
        send_notification "Process Manager" "No processes found" "normal"
        exit 0
    fi
    
    # Show header info
    local header="PID      USER     CPU   MEM   COMMAND              ARGS"
    if [ "$SHOW_ALL_USERS" = true ]; then
        header="Select process to manage (All Users)"
    else
        header="Select process to manage (User: $USER)"
    fi
    
    # Select process
    local selected
    selected=$(echo "$processes" | rofi -dmenu -i -p "Search process:" -mesg "$header" -theme-str 'window {width: 1000px;}')
    
    if [ -z "$selected" ]; then
        exit 0
    fi
    
    # Extract PID and process name
    local pid
    local process_name
    pid=$(extract_pid "$selected")
    process_name=$(extract_process_name "$selected")
    
    if [ -z "$pid" ]; then
        send_notification "Error" "Failed to extract PID" "critical"
        exit 1
    fi
    
    # Show action menu
    local action
    action=$(echo -e "🔪 Kill (SIGTERM)\n💀 Force Kill (SIGKILL)\n⏸️  Stop (SIGSTOP)\n▶️  Continue (SIGCONT)\n📊 Show Details\n🌳 Show Process Tree\n❌ Cancel" | \
        rofi -dmenu -i -p "Action for PID $pid ($process_name):" -theme-str 'window {width: 500px;}')
    
    case "$action" in
        "🔪 Kill (SIGTERM)")
            # Ask for confirmation
            local confirm
            confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Kill process $process_name (PID: $pid)?")
            
            if [ "$confirm" = "Yes" ]; then
                kill_process "$pid" "$process_name" 15
            else
                send_notification "Process Kill" "Cancelled by user" "normal"
            fi
            ;;
        "💀 Force Kill (SIGKILL)")
            # Ask for confirmation with warning
            local confirm
            confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "⚠️  FORCE KILL $process_name (PID: $pid)? This cannot be caught!" -theme-str 'window {width: 600px;}')
            
            if [ "$confirm" = "Yes" ]; then
                kill_process "$pid" "$process_name" 9
            else
                send_notification "Process Kill" "Cancelled by user" "normal"
            fi
            ;;
        "⏸️  Stop (SIGSTOP)")
            if kill -STOP "$pid" 2>/dev/null; then
                send_notification "Process Stopped" "⏸️  Stopped: $process_name (PID: $pid)" "normal"
            else
                send_notification "Process Stop Failed" "Failed to stop process" "critical"
            fi
            ;;
        "▶️  Continue (SIGCONT)")
            if kill -CONT "$pid" 2>/dev/null; then
                send_notification "Process Continued" "▶️  Continued: $process_name (PID: $pid)" "normal"
            else
                send_notification "Process Continue Failed" "Failed to continue process" "critical"
            fi
            ;;
        "📊 Show Details")
            local details
            details=$(get_process_details "$pid")
            if [ -n "$details" ]; then
                echo -e "PROCESS DETAILS:\n\nPID PPID USER %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND\n$details" | \
                    rofi -dmenu -p "Details for PID $pid" -mesg "Press Esc to close" -theme-str 'window {width: 1200px;}'
            fi
            ;;
        "🌳 Show Process Tree")
            show_process_tree "$pid"
            ;;
        *)
            exit 0
            ;;
    esac
}

# Fungsi untuk list processes by name
search_by_name() {
    check_dependencies
    
    local process_name
    process_name=$(rofi -dmenu -p "Enter process name to search:" -theme-str 'window {width: 500px;}')
    
    if [ -z "$process_name" ]; then
        exit 0
    fi
    
    local results
    if [ "$SHOW_ALL_USERS" = true ]; then
        results=$(ps aux | grep -i "$process_name" | grep -v grep | \
            awk '{printf "%-8s %-8s %5s%% %5s%% %s\n", $2, $1, $3, $4, $11}')
    else
        results=$(ps --user "$USER" -o pid,user,%cpu,%mem,comm,args | grep -i "$process_name" | grep -v grep | \
            awk '{printf "%-8s %-8s %5s%% %5s%% %s\n", $1, $2, $3, $4, $5}')
    fi
    
    if [ -z "$results" ]; then
        send_notification "Process Search" "No processes found matching: $process_name" "normal"
        exit 0
    fi
    
    echo -e "PID      USER     CPU   MEM   COMMAND\n$results" | \
        rofi -dmenu -p "Results for: $process_name" -mesg "Found processes" -theme-str 'window {width: 900px;}'
}

# Fungsi untuk kill by name (killall-like)
kill_by_name() {
    check_dependencies
    
    local process_name
    process_name=$(rofi -dmenu -p "Enter process name to kill:" -theme-str 'window {width: 500px;}')
    
    if [ -z "$process_name" ]; then
        exit 0
    fi
    
    # Find matching processes
    local pids
    if [ "$SHOW_ALL_USERS" = true ]; then
        pids=$(pgrep -x "$process_name" || true)
    else
        pids=$(pgrep -u "$USER" -x "$process_name" || true)
    fi
    
    if [ -z "$pids" ]; then
        send_notification "Process Kill" "No processes found: $process_name" "normal"
        exit 0
    fi
    
    local count
    count=$(echo "$pids" | wc -l)
    
    # Ask for confirmation
    local confirm
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Kill $count instance(s) of '$process_name'?")
    
    if [ "$confirm" = "Yes" ]; then
        echo "$pids" | xargs kill -15 2>/dev/null
        send_notification "Process Kill" "✓ Killed $count instance(s) of: $process_name" "normal"
    else
        send_notification "Process Kill" "Cancelled by user" "normal"
    fi
}

# Fungsi help
show_help() {
    cat << EOF
dm-kill - Process manager and killer using rofi

Usage: $(basename "$0") [OPTIONS]

Options:
    -a, --all           Show processes from all users (requires appropriate permissions)
    -s, --search        Search processes by name
    -k, --kill-name     Kill all processes by name
    -h, --help          Show this help message
    
    (no options)        Show interactive process manager
    
Dependencies:
    - rofi
    - ps (from procps)
    - pstree (optional, for process tree view)

Features:
    - Search and kill processes interactively
    - Multiple kill signals (SIGTERM, SIGKILL, SIGSTOP, SIGCONT)
    - View process details
    - View process tree/hierarchy
    - Search by process name
    - Kill multiple processes by name
    - Sorted by memory usage

Signals:
    SIGTERM (15)    - Normal termination (allows cleanup)
    SIGKILL (9)     - Force kill (cannot be caught)
    SIGSTOP (19)    - Pause process
    SIGCONT (18)    - Resume process

Examples:
    $(basename "$0")              # Show process manager
    $(basename "$0") -a           # Show all users' processes
    $(basename "$0") -s           # Search by name
    $(basename "$0") -k           # Kill by name

Configuration:
    Edit SHOW_ALL_USERS variable in script to change default behavior

EOF
}

# Parse command line arguments
case "${1:-}" in
    -a|--all)
        SHOW_ALL_USERS=true
        main
        exit 0
        ;;
    -s|--search)
        search_by_name
        exit 0
        ;;
    -k|--kill-name)
        kill_by_name
        exit 0
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        # No arguments, run main
        main
        exit 0
        ;;
    *)
        echo "Error: Unknown option '$1'" >&2
        echo "Use -h for help" >&2
        exit 1
        ;;
esac

#!/usr/bin/env bash
#
# Script name: dm-usbmount
# Description: Mount/unmount USB drives using rofi. No fancy daemon required.
# Dependencies: rofi, udisks2
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
    
    for cmd in rofi lsblk udisksctl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        local deps_list=$(IFS=', '; echo "${missing_deps[*]}")
        send_notification "Error - Missing Dependencies" "Dependencies tidak ditemukan: $deps_list" "critical"
        echo "Error: Missing dependencies: $deps_list" >&2
        echo "Please install: rofi, udisks2" >&2
        exit 1
    fi
}

# Fungsi untuk menghitung jumlah drive
drive_count() {
    echo "$1" | grep -c "^" 2>/dev/null || echo "0"
}

# Fungsi untuk mendapatkan mountable drives
get_mountable_drives() {
    lsblk -lp -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL 2>/dev/null | \
        awk '/^\/dev\/sd.*part/ && $4 == "" { 
            label = ($5 != "") ? $5 : "No Label"
            print $1 " (" $2 ") - " label 
        }'
}

# Fungsi untuk mendapatkan mounted drives
get_mounted_drives() {
    lsblk -lp -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL 2>/dev/null | \
        awk '/^\/dev\/sd.*part/ && $4 != "" { 
            label = ($5 != "") ? $5 : "No Label"
            print $1 " (" $2 ") - " $4 " - " label 
        }'
}

# Fungsi untuk extract device path dari pilihan
extract_device() {
    local choice="$1"
    echo "$choice" | awk '{print $1}'
}

# Fungsi untuk mount single drive
mount_drive() {
    local device="$1"
    local label="$2"
    
    if udisksctl mount -b "$device" 2>&1; then
        local mount_point
        mount_point=$(lsblk -lp -o NAME,MOUNTPOINT "$device" 2>/dev/null | awk 'NR==2 {print $2}')
        send_notification "USB Mount" "✓ Mounted: ${label}\n📁 Location: ${mount_point}"
        return 0
    else
        send_notification "USB Mount Error" "✗ Failed to mount: ${label}" "critical"
        return 1
    fi
}

# Fungsi untuk unmount single drive
unmount_drive() {
    local device="$1"
    local label="$2"
    
    if udisksctl unmount -b "$device" 2>&1; then
        send_notification "USB Unmount" "✓ Unmounted: ${label}"
        return 0
    else
        send_notification "USB Unmount Error" "✗ Failed to unmount: ${label}" "critical"
        return 1
    fi
}

# Fungsi untuk mount all drives
mount_all() {
    local mountable="$1"
    local count=0
    local failed=0
    
    while IFS= read -r drive; do
        if [ -n "$drive" ]; then
            local device
            device=$(extract_device "$drive")
            if mount_drive "$device" "$drive"; then
                ((count++))
            else
                ((failed++))
            fi
        fi
    done <<< "$mountable"
    
    if [ $failed -eq 0 ]; then
        send_notification "USB Mount All" "✓ Successfully mounted $count drive(s)"
    else
        send_notification "USB Mount All" "⚠ Mounted: $count, Failed: $failed" "normal"
    fi
}

# Fungsi untuk unmount all drives
unmount_all() {
    local mounted="$1"
    local count=0
    local failed=0
    
    while IFS= read -r drive; do
        if [ -n "$drive" ]; then
            local device
            device=$(extract_device "$drive")
            if unmount_drive "$device" "$drive"; then
                ((count++))
            else
                ((failed++))
            fi
        fi
    done <<< "$mounted"
    
    if [ $failed -eq 0 ]; then
        send_notification "USB Unmount All" "✓ Successfully unmounted $count drive(s)"
    else
        send_notification "USB Unmount All" "⚠ Unmounted: $count, Failed: $failed" "normal"
    fi
}

# Fungsi untuk mount menu
mount_menu() {
    check_dependencies
    
    local mountable
    mountable=$(get_mountable_drives)
    
    if [ -z "$mountable" ]; then
        send_notification "USB Mount" "No unmounted USB drives found" "normal"
        exit 0
    fi
    
    local count
    count=$(drive_count "$mountable")
    
    # Add "Mount All" option if more than one drive
    local options="$mountable"
    if [ "$count" -gt 1 ]; then
        options="🔄 Mount All Drives
$mountable"
    fi
    
    local chosen
    chosen=$(echo "$options" | rofi -dmenu -i -p "Select drive to mount:" -theme-str 'window {width: 700px;}')
    
    if [ -z "$chosen" ]; then
        exit 0
    fi
    
    if [ "$chosen" = "🔄 Mount All Drives" ]; then
        mount_all "$mountable"
    else
        local device
        device=$(extract_device "$chosen")
        mount_drive "$device" "$chosen"
    fi
}

# Fungsi untuk unmount menu
unmount_menu() {
    check_dependencies
    
    local mounted
    mounted=$(get_mounted_drives)
    
    if [ -z "$mounted" ]; then
        send_notification "USB Unmount" "No mounted USB drives found" "normal"
        exit 0
    fi
    
    local count
    count=$(drive_count "$mounted")
    
    # Add "Unmount All" option if more than one drive
    local options="$mounted"
    if [ "$count" -gt 1 ]; then
        options="🔄 Unmount All Drives
$mounted"
    fi
    
    local chosen
    chosen=$(echo "$options" | rofi -dmenu -i -p "Select drive to unmount:" -theme-str 'window {width: 700px;}')
    
    if [ -z "$chosen" ]; then
        exit 0
    fi
    
    if [ "$chosen" = "🔄 Unmount All Drives" ]; then
        unmount_all "$mounted"
    else
        local device
        device=$(extract_device "$chosen")
        unmount_drive "$device" "$chosen"
    fi
}

# Fungsi untuk main menu
main_menu() {
    check_dependencies
    
    local mountable
    local mounted
    mountable=$(get_mountable_drives)
    mounted=$(get_mounted_drives)
    
    local mountable_count
    local mounted_count
    mountable_count=$(drive_count "$mountable")
    mounted_count=$(drive_count "$mounted")
    
    # Build menu options
    local menu_options=""
    
    if [ "$mountable_count" -gt 0 ]; then
        menu_options+="💾 Mount USB Drive ($mountable_count available)\n"
    fi
    
    if [ "$mounted_count" -gt 0 ]; then
        menu_options+="⏏️  Unmount USB Drive ($mounted_count mounted)\n"
    fi
    
    if [ "$mountable_count" -eq 0 ] && [ "$mounted_count" -eq 0 ]; then
        send_notification "USB Manager" "No USB drives detected" "normal"
        exit 0
    fi
    
    menu_options+="📋 List All Drives\n❌ Exit"
    
    local choice
    choice=$(echo -e "$menu_options" | rofi -dmenu -i -p "USB Manager:" -theme-str 'window {width: 500px;}')
    
    case "$choice" in
        "💾 Mount USB Drive"*)
            mount_menu
            ;;
        "⏏️  Unmount USB Drive"*)
            unmount_menu
            ;;
        "📋 List All Drives")
            list_all_drives
            ;;
        *)
            exit 0
            ;;
    esac
}

# Fungsi untuk list semua drives
list_all_drives() {
    local all_info
    all_info=$(lsblk -lp -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL,FSTYPE 2>/dev/null | \
        awk '/^\/dev\/sd.*part/ { 
            status = ($4 != "") ? "✓ MOUNTED" : "○ UNMOUNTED"
            label = ($5 != "") ? $5 : "No Label"
            fs = ($6 != "") ? $6 : "Unknown"
            printf "%-10s %6s  %-12s  %-20s  %s  %s\n", $1, $2, status, $4, label, fs
        }')
    
    if [ -z "$all_info" ]; then
        send_notification "USB Manager" "No USB drives detected" "normal"
        return
    fi
    
    echo -e "DEVICE     SIZE   STATUS        MOUNTPOINT            LABEL  FSTYPE\n$all_info" | \
        rofi -dmenu -p "All USB Drives" -mesg "Press Esc to close" -theme-str 'window {width: 1000px;}'
}

# Fungsi help
show_help() {
    cat << EOF
dm-usbmount - Mount/unmount USB drives using rofi

Usage: $(basename "$0") [OPTIONS]

Options:
    -m, --mount         Show mount menu
    -u, --unmount       Show unmount menu
    -l, --list          List all USB drives
    -h, --help          Show this help message
    
    (no options)        Show main interactive menu
    
Dependencies:
    - rofi
    - udisks2 (udisksctl)
    - util-linux (lsblk)

Features:
    - Mount/unmount USB drives with one click
    - Mount/unmount all drives at once
    - View all USB drives and their status
    - Automatic notifications
    - No daemon required

Examples:
    $(basename "$0")              # Show interactive menu
    $(basename "$0") -m           # Go directly to mount menu
    $(basename "$0") -u           # Go directly to unmount menu
    $(basename "$0") -l           # List all drives

EOF
}

# Parse command line arguments
case "${1:-}" in
    -m|--mount)
        mount_menu
        exit 0
        ;;
    -u|--unmount)
        unmount_menu
        exit 0
        ;;
    -l|--list)
        list_all_drives
        exit 0
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        # No arguments, show main menu
        main_menu
        exit 0
        ;;
    *)
        echo "Error: Unknown option '$1'" >&2
        echo "Use -h for help" >&2
        exit 1
        ;;
esac

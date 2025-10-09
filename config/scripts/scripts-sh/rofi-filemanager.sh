#!/bin/bash

# rofi-filemanager.sh - Simple file manager using Rofi
# Author: Claude

# Temporary files for clipboard operations
CLIPBOARD_FILE="/tmp/rofi_filemanager_clipboard"
CLIPBOARD_OP="/tmp/rofi_filemanager_operation"

# Default starting directory
if [ -z "$1" ]; then
    CURRENT_DIR="$HOME"
else
    CURRENT_DIR="$1"
fi

# Make sure directory path ends with '/'
if [[ "$CURRENT_DIR" != */ ]]; then
    CURRENT_DIR="$CURRENT_DIR/"
fi

# Function to show notification
notify() {
    if command -v notify-send >/dev/null; then
        notify-send "Rofi File Manager" "$1"
    else
        echo "$1"
    fi
}

# Function to handle file operations
handle_operation() {
    local file="$1"
    local operation="$2"
    
    case $operation in
        "Copy")
            echo "$file" > "$CLIPBOARD_FILE"
            echo "copy" > "$CLIPBOARD_OP"
            notify "Copied: $(basename "$file")"
            ;;
        "Cut")
            echo "$file" > "$CLIPBOARD_FILE"
            echo "cut" > "$CLIPBOARD_OP"
            notify "Cut: $(basename "$file")"
            ;;
        "Paste")
            if [ -f "$CLIPBOARD_FILE" ]; then
                src_file=$(cat "$CLIPBOARD_FILE")
                op_type=$(cat "$CLIPBOARD_OP")
                
                if [ -n "$src_file" ] && [ -e "$src_file" ]; then
                    dest="$CURRENT_DIR$(basename "$src_file")"
                    
                    if [ "$op_type" = "copy" ]; then
                        if [ -d "$src_file" ]; then
                            cp -r "$src_file" "$dest"
                        else
                            cp "$src_file" "$dest"
                        fi
                        notify "Copied: $(basename "$src_file") to $CURRENT_DIR"
                    elif [ "$op_type" = "cut" ]; then
                        mv "$src_file" "$dest"
                        notify "Moved: $(basename "$src_file") to $CURRENT_DIR"
                        rm "$CLIPBOARD_FILE"
                        rm "$CLIPBOARD_OP"
                    fi
                else
                    notify "Source file no longer exists!"
                fi
            else
                notify "Clipboard is empty!"
            fi
            ;;
        "Delete")
            local filename=$(basename "$file")
            if [ -d "$file" ]; then
                rm -rf "$file"
                notify "Deleted directory: $filename"
            else
                rm "$file"
                notify "Deleted file: $filename"
            fi
            ;;
        "Rename")
            local old_name=$(basename "$file")
            local new_name=$(rofi -dmenu -p "New name for $old_name:" -l 0)
            
            if [ -n "$new_name" ] && [ "$new_name" != "$old_name" ]; then
                local new_path="${file%/*}/$new_name"
                mv "$file" "$new_path"
                notify "Renamed: $old_name to $new_name"
            fi
            ;;
        "Properties")
            if [ -f "$file" ]; then
                size=$(du -h "$file" | cut -f1)
                perm=$(stat -c "%A" "$file")
                owner=$(stat -c "%U" "$file")
                group=$(stat -c "%G" "$file")
                modified=$(stat -c "%y" "$file")
                
                info="File: $(basename "$file")\nSize: $size\nPermissions: $perm\nOwner: $owner\nGroup: $group\nModified: $modified"
                echo -e "$info" | rofi -dmenu -p "Properties" -l 6
            elif [ -d "$file" ]; then
                size=$(du -sh "$file" | cut -f1)
                perm=$(stat -c "%A" "$file")
                owner=$(stat -c "%U" "$file")
                group=$(stat -c "%G" "$file")
                modified=$(stat -c "%y" "$file")
                count=$(find "$file" -type f | wc -l)
                
                info="Directory: $(basename "$file")\nSize: $size\nFiles: $count\nPermissions: $perm\nOwner: $owner\nGroup: $group\nModified: $modified"
                echo -e "$info" | rofi -dmenu -p "Properties" -l 7
            fi
            ;;
    esac
}

# Function to show file options
file_options() {
    local file="$1"
    local options="Open\nCopy\nCut\nDelete\nRename\nProperties"
    
    if [ -f "$CLIPBOARD_FILE" ]; then
        options="Open\nCopy\nCut\nPaste\nDelete\nRename\nProperties"
    fi
    
    local choice=$(echo -e "$options" | rofi -dmenu -p "$(basename "$file")")
    
    case $choice in
        "Open")
            if [ -d "$file" ]; then
                "$0" "$file"
            else
                xdg-open "$file" &
            fi
            ;;
        "Copy"|"Cut"|"Delete"|"Paste"|"Rename"|"Properties")
            handle_operation "$file" "$choice"
            ;;
    esac
}

# Main loop for directory browsing
while true; do
    # Get directory contents with icons
    content=""
    
    # Add navigation options
    content+="󰜴 ..\n"
    content+="󰋜 Home\n"
    content+="󰴦 Refresh\n"
    
    # Add paste option if clipboard has content
    if [ -f "$CLIPBOARD_FILE" ]; then
        content+="󰆏 Paste here\n"
    fi
    
    # Add files and directories with icons
    while IFS= read -r item; do
        name=$(basename "$item")
        
        if [ -d "$item" ]; then
            content+="󰉋 $name\n"  # Directory icon
        else
            # Choose icon based on file extension
            case "${name##*.}" in
                txt|md|conf|log)
                    content+="󰈙 $name\n"  # Text file icon
                    ;;
                jpg|jpeg|png|gif|bmp|svg)
                    content+="󰋩 $name\n"  # Image file icon
                    ;;
                mp3|wav|ogg|flac)
                    content+="󰎆 $name\n"  # Audio file icon
                    ;;
                mp4|mkv|avi|mov)
                    content+="󰕧 $name\n"  # Video file icon
                    ;;
                pdf)
                    content+="󰈦 $name\n"  # PDF icon
                    ;;
                zip|tar|gz|xz|bz2|7z)
                    content+="󰛫 $name\n"  # Archive icon
                    ;;
                sh|bash|py|rb|js|pl)
                    content+="󰺵 $name\n"  # Script icon
                    ;;
                *)
                    content+="󰈔 $name\n"  # Default file icon
                    ;;
            esac
        fi
    done < <(ls -A "$CURRENT_DIR" | sort | while read -r name; do echo "$CURRENT_DIR$name"; done)
    
    # Show the directory contents in rofi
    selection=$(echo -e "$content" | rofi -dmenu -p "($CURRENT_DIR)" -i -l 20)
    
    # Check if user cancelled
    if [ -z "$selection" ]; then
        exit 0
    fi
    
    # Handle selection
    item_name=${selection#* }  # Remove icon prefix
    
    case "$selection" in
        "󰜴 ..")
            CURRENT_DIR=$(dirname "$CURRENT_DIR")/
            ;;
        "󰋜 Home")
            CURRENT_DIR="$HOME/"
            ;;
        "󰴦 Refresh")
            continue
            ;;
        "󰆏 Paste here")
            handle_operation "$CURRENT_DIR" "Paste"
            ;;
        *)
            # Handle file or directory
            full_path="$CURRENT_DIR$item_name"
            if [ -d "$full_path" ]; then
                # Handle directory specially
                options="Open\nCopy\nCut\nDelete\nRename\nProperties"
                if [ -f "$CLIPBOARD_FILE" ]; then
                    options="Open\nCopy\nCut\nPaste\nDelete\nRename\nProperties"
                fi
                
                choice=$(echo -e "$options" | rofi -dmenu -p "$item_name")
                
                case $choice in
                    "Open")
                        CURRENT_DIR="$full_path/"
                        ;;
                    "Copy"|"Cut"|"Delete"|"Paste"|"Rename"|"Properties")
                        handle_operation "$full_path" "$choice"
                        ;;
                esac
            else
                # Regular file
                file_options "$full_path"
            fi
            ;;
    esac
done

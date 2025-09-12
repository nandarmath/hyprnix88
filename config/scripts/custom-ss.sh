#!/bin/bash

# Simple Polaroid Screenshot Script for Hyprland
# Uses grim + slurp only (most reliable)
# Dependencies: grim, slurp, imagemagick

# Configuration
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
POLAROID_DIR="$HOME/Pictures/Polaroids"
BORDER_WIDTH=30
BOTTOM_BORDER=30
SHADOW_BLUR=10
SHADOW_OFFSET=5
BORDER_COLOR="#FFFFFF"
# WHITE_COLOR="#FF8C00"
SHADOW_COLOR="#00000040"
STAMP_TEXT=" R-nandar  "

# Create directories
mkdir -p "$SCREENSHOTS_DIR" "$POLAROID_DIR"

# Function to show notification
#notify_user() {
#   if command -v notify-send >/dev/null 2>&1; then
#       notify-send "Polaroid Screenshot" "$1" -i camera-photo
#   fi
#   echo "$1"
#}

# Function to create polaroid effect
create_polaroid() {
    local input_file="$1"
    local output_file="$2"
    
    echo "🎨 Creating polaroid effect..."
    
    # Create polaroid effect using ImageMagick
    magick "$input_file" \
        -bordercolor "$BORDER_COLOR" \
        -border "${BORDER_WIDTH}x${BORDER_WIDTH}" \
        -bordercolor "$BORDER_COLOR" \
        -border "0x$((BOTTOM_BORDER - BORDER_WIDTH))" \
        -background transparent \
        -font "MesloLGSDZ-Nerd-Font-Mono-Italic" -pointsize 20 -fill orange -annotate +30+28 "$STAMP_TEXT" \
        \( +clone -background "$SHADOW_COLOR" -shadow "${SHADOW_BLUR}x${SHADOW_OFFSET}+${SHADOW_OFFSET}+${SHADOW_OFFSET}" \) \
        +swap -background transparent -layers merge +repage \
        "$output_file"
}

# Check dependencies
echo "🔍 Checking dependencies..."

# Check critical tools
if ! command -v grim >/dev/null 2>&1; then
    echo "❌ Error: grim not found"
    echo "📦 Install: sudo pacman -S grim"
    exit 1
fi

if ! command -v slurp >/dev/null 2>&1; then
    echo "❌ Error: slurp not found"
    echo "📦 Install: sudo pacman -S slurp"
    exit 1
fi

if ! command -v convert >/dev/null 2>&1; then
    echo "❌ Error: imagemagick not found"
    echo "📦 Install: sudo pacman -S imagemagick"
    exit 1
fi

echo "✅ All dependencies found!"
echo ""

# Handle help argument
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "📸 Simple Polaroid Screenshot Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "How to use:"
    echo "  1. Run this script"
    echo "  2. Wait for crosshair cursor"
    echo "  3. CLICK and DRAG to select area"
    echo "  4. RELEASE mouse to confirm"
    echo ""
    echo "Output: ~/Pictures/Polaroids/"
    exit 0
fi

# Main screenshot process
echo "📸 Starting polaroid screenshot..."
notify_user "Select area for polaroid screenshot..."

# Generate filename
timestamp=$(date +"%Y%m%d_%H%M%S")
temp_file="$SCREENSHOTS_DIR/temp_${timestamp}.png"
output_file="$POLAROID_DIR/polaroid_${timestamp}.png"

echo ""
echo "📋 INSTRUCTIONS:"
echo "   • Cursor akan berubah jadi crosshair (+)"
echo "   • KLIK dan DRAG area yang ingin di-screenshot"
echo "   • LEPAS tombol mouse untuk konfirmasi"
echo "   • Tekan ESC untuk batal"
echo ""

# Take screenshot with grim + slurp
echo "🎯 Launching selection tool..."

if selection=$(slurp 2>/dev/null); then
    echo "✅ Area selected: $selection"
    echo "📷 Capturing screenshot..."
    
    if grim -g "$selection" "$temp_file"; then
        if [[ -f "$temp_file" && -s "$temp_file" ]]; then
            echo "✅ Screenshot captured: $(ls -lh "$temp_file" | awk '{print $5}')"
            
            # Create polaroid effect
            if create_polaroid "$temp_file" "$output_file"; then
                # Clean up temp file
                rm "$temp_file"
                
                echo "✅ Polaroid effect applied!"
                
                # Copy to clipboard if possible
                if command -v wl-copy >/dev/null 2>&1; then
                    wl-copy < "$output_file"
                    notify_user "✅ Polaroid saved and copied to clipboard!"
                else
                    notify_user "✅ Polaroid saved!"
                fi
                
                # Try to open with image viewer
                # for viewer in imv feh eog xviewer; do
                #     if command -v "$viewer" >/dev/null 2>&1; then
                #         "$viewer" "$output_file" &
                #         break
                #     fi
                # done
                
                echo "📁 Saved to: $output_file"
                echo "🎉 Done!"
                
            else
                echo "❌ Failed to create polaroid effect"
                echo "🐛 Debug: temp file saved at $temp_file"
                exit 1
            fi
        else
            echo "❌ Screenshot file is empty or missing"
            exit 1
        fi
    else
        echo "❌ Failed to capture screenshot"
        exit 1
    fi
else
    echo "📝 Screenshot cancelled by user"
    notify_user "Screenshot cancelled"
    exit 0
fi

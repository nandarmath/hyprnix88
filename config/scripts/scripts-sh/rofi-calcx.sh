#!/bin/bash

# Rofi Calculator dengan Kalker Backend
# Pastikan kalker sudah terinstall: cargo install kalker

# Konfigurasi tampilan rofi
ROFI_PROMPT="🧮 Calculator"
ROFI_WIDTH=400
ROFI_LINES=10

# File untuk menyimpan history (opsional)
HISTORY_FILE="$HOME/.cache/rofi-calculator-history"

# Fungsi untuk menjalankan kalkulasi
calculate() {
    local expression="$1"
    
    # Cek jika input kosong
    if [[ -z "$expression" ]]; then
        echo ""
        return
    fi
    
    # Cek jika input adalah perintah khusus
    case "$expression" in
        "clear"|"c")
            > "$HISTORY_FILE"
            echo "History cleared"
            return
            ;;
        "history"|"h")
            if [[ -f "$HISTORY_FILE" ]]; then
                cat "$HISTORY_FILE"
            else
                echo "No history found"
            fi
            return
            ;;
        "help"|"?")
            echo "Commands: clear/c (clear history), history/h (show history), help/? (this help)"
            echo "Examples: 2+2, sin(45), sqrt(16), 2^3, pi*2, e^2"
            echo "Usage: Press Enter on result to copy to clipboard"
            return
            ;;
    esac
    
    # Jalankan kalkulasi dengan kalker
    local result
    result=$(echo "$expression" | kalker 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$result" ]]; then
        # Simpan ke history jika kalkulasi berhasil
        echo "$expression = $result" >> "$HISTORY_FILE"
        echo "$result"
    else
        echo "Error: Invalid expression"
    fi
}

# Fungsi utama rofi
main() {
    # Buat direktori cache jika belum ada
    mkdir -p "$(dirname "$HISTORY_FILE")"
    
    # Loop utama
    while true; do
        # Siapkan opsi untuk rofi
        local options=""
        
        # Tambahkan history jika ada
        if [[ -f "$HISTORY_FILE" ]] && [[ -s "$HISTORY_FILE" ]]; then
            options+="📜 Recent calculations:\n"
            options+=$(tail -5 "$HISTORY_FILE" | sed 's/^/   /')
            options+="\n\n"
        fi
        
        # Tambahkan bantuan
        options+="💡 Commands: help, clear, history\n"
        options+="📝 Examples: 2+2, sin(45°), sqrt(16), pi*2\n"
        options+="\n"
        
        # Jalankan rofi dengan mode input
        local input
        input=$(echo -e "$options" | rofi \
            -dmenu \
            -p "$ROFI_PROMPT" \
            -width "$ROFI_WIDTH" \
            -lines "$ROFI_LINES" \
            -i)
        
        # Cek jika user membatalkan
        if [[ $? -ne 0 ]]; then
            break
        fi
        
        # Ambil input dari user jika kosong (user mengetik langsung)
        if [[ -z "$input" ]]; then
            input=$(rofi -dmenu -p "$ROFI_PROMPT" -width "$ROFI_WIDTH" -lines 1)
            if [[ $? -ne 0 ]] || [[ -z "$input" ]]; then
                continue
            fi
        fi
        
        # Bersihkan input dari markup dan whitespace
        input=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^[📜💡📝][[:space:]]*//')
        
        # Skip jika input adalah header, contoh, atau perintah bantuan
        if [[ "$input" =~ ^(Recent calculations|Commands|Examples): ]] || 
           [[ "$input" =~ ^(Recent calculations|Commands|Examples)$ ]]; then
            continue
        fi
        
        # Hitung hasil
        local result
        result=$(calculate "$input")
        
        # Tampilkan hasil jika ada
        if [[ -n "$result" ]]; then
            # Copy ke clipboard langsung saat Enter ditekan
            if command -v wl-copy &> /dev/null; then
                echo "$result" | wl-copy
                notify-send "Calculator" "Result: $result (copied to clipboard)" 2>/dev/null || echo "Result: $result (copied)"
            elif command -v xclip &> /dev/null; then
                echo "$result" | xclip -selection clipboard
                notify-send "Calculator" "Result: $result (copied to clipboard)" 2>/dev/null || echo "Result: $result (copied)"
            else
                echo "Result: $result (clipboard not available)"
            fi
            
            # Tampilkan hasil sebentar
            echo "$input = $result" | rofi \
                -dmenu \
                -p "Result (copied to clipboard)" \
                -width "$ROFI_WIDTH" \
                -lines 1 \
                -no-custom
        fi
    done
}

# Cek jika kalker terinstall
if ! command -v kalker &> /dev/null; then
    rofi -e "Error: kalker not found. Please install it with: cargo install kalker"
    exit 1
fi

# Cek jika rofi terinstall
if ! command -v rofi &> /dev/null; then
    echo "Error: rofi not found. Please install rofi first."
    exit 1
fi

# Cek clipboard tools
if ! command -v wl-copy &> /dev/null && ! command -v xclip &> /dev/null; then
    echo "Warning: Neither wl-copy (Wayland) nor xclip (X11) found."
    echo "Install one of them for clipboard functionality:"
    echo "  - Wayland: sudo apt install wl-clipboard"
    echo "  - X11: sudo apt install xclip"
fi

# Jalankan program utama
main
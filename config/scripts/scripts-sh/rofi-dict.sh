#!/usr/bin/env bash

# kamus-interaktif.sh - Script pencarian kamus interaktif menggunakan rofi dan sdcv
# Author: Claude
# Tanggal: May 19, 2025

# Pastikan dependensi terpenuhi
check_dependencies() {
    local deps=("rofi" "sdcv" "sed" "awk" "grep")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Beberapa dependensi tidak ditemukan. Silakan install:"
        for dep in "${missing_deps[@]}"; do
            echo " - $dep"
        done
        exit 1
    fi
}

# Inisialisasi konfigurasi rofi
ROFI_CONFIG="-theme-str 'window {width: 70%; height: 70%;}' -theme-str 'listview {lines: 15;}' -theme-str 'textbox-prompt-colon {str: \"📚\";}'"

# Fungsi untuk menangani mode kamus rofi
handle_rofi_kamus() {
    # Mode kamus rofi
    if [ -z "$ROFI_RETV" ]; then
        # Mode inisialisasi - tampilkan prompt awal
        echo -en "\0prompt\x1fKamus\n"
        echo -en "\0message\x1fKetik kata untuk pencarian...\n"
        echo -en "\0markup-rows\x1ftrue\n"
        exit 0
    elif [ "$ROFI_RETV" = "1" ]; then
        # Pengguna memilih item dari daftar (tidak digunakan dalam script ini)
        exit 0
    else
        # Mode input - pengguna telah mengetik sesuatu
        local kata="$1"
        local minimal_length=2
        
        # Jika input kosong atau terlalu pendek
        if [ -z "$kata" ] || [ ${#kata} -lt $minimal_length ]; then
            echo -en "\0message\x1fKetik minimal $minimal_length karakter untuk mencari...\n"
            echo "Menunggu input..."
            exit 0
        fi
        
        # Jalankan pencarian di sdcv dan format hasilnya
        local hasil=$(sdcv --data-dir ~/hyprnix/config/scripts/stardict -n --utf8-output --color "$kata" 2>&1)
        
        # Hapus header sdcv yang tidak diperlukan
        hasil=$(echo "$hasil" | sed -e '1,/^$/d')
        
        # Filter dan format hasil pencarian
        if echo "$hasil" | grep -q "Nothing similar to"; then
            echo -en "\0message\x1fTidak ada hasil untuk \"$kata\"\n"
            echo "Tidak ada hasil ditemukan untuk \"$kata\""
        else
            # Format hasil dengan markdown untuk rofi
            echo -en "\0message\x1fHasil pencarian untuk \"$kata\":\n"
            
            # Proses hasil dan format untuk ditampilkan di rofi
            formatted_result=$(echo "$hasil" | awk -v RS='' -v FS='\n' '{
                # Extract dictionary name
                dict = $1;
                gsub(/-->/, "➜", dict);
                
                # Process definition content
                result = "" dict "\n";
                
                # Skip the first line (dictionary name)
                for(i=2; i<=NF; i++) {
                    line = $i;
                    
                    # Format headword/pronunciation line
                    if(i==2) {
                        gsub(/^[ \t]+/, "", line);
                        result = result "<span color=\"#2ecc71\"><b>" line "</b></span>\n";
                    }
                    # Format word type (noun, verb, etc)
                    else if(line ~ /^[ \t]*[0-9]*\.[ \t]*\[[a-z]+\.?\]/) {
                        gsub(/^[ \t]*/, "", line);
                        result = result "\n<span color=\"#3498db\">" line "</span>\n";
                    }
                    # Format definitions
                    else if(line ~ /^[ \t]*[0-9]+\./) {
                        gsub(/^[ \t]*/, "", line);
                        result = result "<span color=\"#e74c3c\">• " line "</span>\n";
                    }
                    # Format examples
                    else if(line ~ /^[ \t]*[a-z]+\./ || line ~ /^[ \t]*Example:/) {
                        gsub(/^[ \t]*/, "", line);
                        result = result "<i><span color=\"#9b59b6\">  " line "</span></i>\n";
                    }
                    else {
                        gsub(/^[ \t]*/, "", line);
                        result = result "  " line "\n";
                    }
                }
                print result;
            }')
            
            echo -e "$formatted_result"
        fi
        exit 0
    fi
}

# Main function
main() {
    check_dependencies
    
    if [ -z "$ROFI_OUTSIDE" ]; then
        # First run - launch rofi in script mode
        export ROFI_OUTSIDE=1
        exec rofi -show kamus -modi "kamus:$0"
    else
        # Handle rofi script mode
        handle_rofi_kamus "$@"
    fi
}

# Run the script
main "$@"

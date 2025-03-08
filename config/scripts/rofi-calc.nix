{ pkgs ? import <nixpkgs> { } }:

let
  rofiCalc = pkgs.writeShellScriptBin "rofi-calc" ''
    # Pastikan dependensi tersedia dalam path
    PATH=${pkgs.rofi}/bin:${pkgs.kalker}/bin:${pkgs.wl-clipboard}/bin:$PATH

    # Fungsi untuk membersihkan saat keluar
    cleanup() {
        rm -f "$INPUT_FILE" "$RESULT_FILE"
        exit 0
    }

    # Tangkap sinyal interupsi
    trap cleanup SIGINT SIGTERM

    # Buat file sementara untuk input dan hasil
    INPUT_FILE=$(mktemp)
    RESULT_FILE=$(mktemp)

    # Buat named pipe untuk komunikasi antara proses
    PIPE=$(mktemp -u)
    mkfifo "$PIPE"

    # Jalankan kalker di latar belakang dengan mode interaktif
    (
        while true; do
            if read -r expr < "$PIPE"; then
                if [[ -n "$expr" && ! "$expr" =~ ^Masukkan.* && ! "$expr" =~ .*=.* ]]; then
                    # Hitung dengan kalker dan simpan hasilnya
                    result=$(echo "$expr" | kalker 2>/dev/null)
                    if [ $? -eq 0 ]; then
                        echo "$expr = $result" > "$RESULT_FILE"
                    else
                        echo "$expr = Error" > "$RESULT_FILE"
                    fi
                fi
            fi
            sleep 0.1
        done
    ) &
    KALKER_PID=$!

    # Fungsi untuk menghentikan proses latar belakang saat keluar
    cleanup_with_bg() {
        kill $KALKER_PID 2>/dev/null
        rm -f "$INPUT_FILE" "$RESULT_FILE" "$PIPE"
        exit 0
    }
    trap cleanup_with_bg SIGINT SIGTERM

    # Tambahkan instruksi awal
    echo "Masukkan perhitungan matematika..." > "$RESULT_FILE"
    echo "Tekan Enter pada hasil untuk menyalin ke clipboard" >> "$RESULT_FILE"
    echo "Ketik 'q' untuk keluar" >> "$RESULT_FILE"

    # Variabel untuk menyimpan input terakhir
    LAST_INPUT=""

    # Loop utama untuk rofi
    while true; do
        # Tampilkan rofi dengan hasil terkini
        SELECTION=$(rofi -dmenu -p "Kalker" \
                        -theme-str 'window {width: 600px;}' \
                        -theme-str 'listview {lines: 7; fixed-height: false;}' \
                        -theme-str 'entry {placeholder: "Masukkan perhitungan...";}' \
                        -theme-str 'inputbar {children: [prompt, entry];}' \
                        -mesg "Kalkulator Real-time - Hasil akan disalin ke clipboard" \
                        -lines 7 < "$RESULT_FILE")
        
        # Keluar jika pengguna membatalkan atau menekan 'q'
        if [ -z "$SELECTION" ] || [ "$SELECTION" = "q" ]; then
            cleanup_with_bg
        fi
        
        # Jika pengguna memilih hasil (berisi '='), salin ke clipboard
        if [[ "$SELECTION" == *"="* ]]; then
            # Ekstrak hasil (bagian setelah '=')
            RESULT=$(echo "$SELECTION" | sed 's/.*= *//')
            
            # Salin ke clipboard menggunakan wl-copy
            echo -n "$RESULT" | wl-copy
            
            # Tambahkan pesan konfirmasi
            echo "Disalin: $RESULT" > "$INPUT_FILE"
            cat "$RESULT_FILE" >> "$INPUT_FILE"
            cp "$INPUT_FILE" "$RESULT_FILE"
        else
            # Jika input baru berbeda dari input terakhir, kirim ke kalker
            if [ "$SELECTION" != "$LAST_INPUT" ] && [ "$SELECTION" != "Masukkan perhitungan matematika..." ] && \
               [ "$SELECTION" != "Tekan Enter pada hasil untuk menyalin ke clipboard" ] && \
               [ "$SELECTION" != "Ketik 'q' untuk keluar" ] && \
               [[ ! "$SELECTION" == Disalin:* ]]; then
                LAST_INPUT="$SELECTION"
                echo "$SELECTION" > "$PIPE"
                # Berikan waktu sedikit untuk kalker memproses
                sleep 0.1
            fi
        fi
    done
  '';
in
pkgs.mkShell {
  name = "rofi-calculator-env";
  buildInputs = [
    pkgs.rofi
    pkgs.kalker
    pkgs.wl-clipboard
    rofiCalc
  ];
  
  shellHook = ''
    echo "Rofi Calculator environment loaded!"
    echo "Run the calculator with: rofi-calc"
  '';
}

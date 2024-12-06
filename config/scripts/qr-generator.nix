{ pkgs ? import <nixpkgs> {}, 
}:

  pkgs.writeShellScriptBin "qr-generator" ''
    # QR Generator by Rania Amina (Nix adaptation)
    
    # Fungsi untuk mencetak penggunaan
    usage() {
      echo "Penggunaan: $0 nama_berkas.csv logo.png [c]"
      exit 1
    }

    # Memeriksa argumen
    if [[ $# -lt 2 || $# -gt 3 ]]; then
      usage
    fi

    file="$1"
    logo="$2"
    color_param=""

    # Memeriksa parameter opsional warna
    if [[ $# -eq 3 && "$3" == "c" ]]; then
      color_param="-c"
    fi

    # Memeriksa ekstensi file CSV
    if [[ "''${file##*.}" != "csv" ]]; then
      echo "Maaf, QR Generator hanya mendukung berkas *.csv!"
      exit 1
    fi

    # Memeriksa keberadaan file logo
    if [[ ! -f "$logo" ]]; then
      echo "Maaf, file logo $logo tidak ditemukan!"
      exit 1
    fi

    # Membuat direktori output
    mkdir -p Hasil

    # Proses file CSV
    tail -n +2 "$file" | while IFS=',' read -r var1 var2 var3 var4; do
      echo "$var1 - $var2 - $var3"
      
      # Generate QR-code dengan pilihan warna opsional
      if [[ -n "$color_param" ]]; then
        amzqr "$var1 $var2 $var3" -p "$logo" -n "Hasil/$var4".png -c
      else
        amzqr "$var1 $var2 $var3" -p "$logo" -n "Hasil/$var4".png
      fi
    done
  ''



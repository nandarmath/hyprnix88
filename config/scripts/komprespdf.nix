{ pkgs ? import <nixpkgs> {} }:

let
  ghostscript = pkgs.ghostscript;
in
pkgs.writeScriptBin "komprespdf" ''
  #!${pkgs.bash}/bin/bash

  # Cek jumlah parameter
  if [ $# -lt 1 ]; then
    echo "Penggunaan: komprespdf file.pdf [-r resolution]"
    echo "  -r: Resolusi gambar (default: 105)"
    exit 1
  fi

  # Set nilai default untuk resolusi
  resolution=105

  # Parse parameter
  while [[ $# -gt 0 ]]; do
    case $1 in
      -r)
        shift
        resolution=$1
        shift
        ;;
      *)
        file=$1
        shift
        ;;
    esac
  done

  # Validasi file input
  if [ ! -f "$file" ]; then
    echo "Error: File '$file' tidak ditemukan"
    exit 1
  fi

  # Buat direktori HasilKompres jika belum ada
  mkdir -p HasilKompres

  # Kompres PDF
  ${ghostscript}/bin/gs \
    -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.4 \
    -dDownsampleColorImages=true \
    -dColorImageResolution=$resolution \
    -dNOPAUSE \
    -dBATCH \
    -sOutputFile="./HasilKompres/$file" \
    "$file"

  if [ $? -eq 0 ]; then
    echo "File berhasil dikompres: HasilKompres/$file"
    echo "Resolusi yang digunakan: $resolution"
  else
    echo "Terjadi kesalahan saat mengkompres file"
    exit 1
  fi
''

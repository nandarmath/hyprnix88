{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "pdf-extractor";
  version = "2.15";

  src = ./pdfextract.sh; # Make sure to replace with the actual path or use fetchurl for remote script

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/pdf-extractor
    chmod +x $out/bin/pdf-extractor
  '';

  buildInputs = [
    pkgs.pdftk
    pkgs.inkscape
    pkgs.ghostscript
  ];

  meta = with pkgs.lib; {
    description = "A simple PDF extractor tool with support for SVG and PNG output";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ yourGithubUsername ];
  };
}


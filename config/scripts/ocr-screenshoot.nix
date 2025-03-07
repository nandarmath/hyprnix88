{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "ocr-screenshot" ''
  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp $SLURP_ARGS)" tmp.png && \
  ${pkgs.tesseract}/bin/tesseract tmp.png - | \
  ${pkgs.wl-clipboard}/bin/wl-copy && \
  rm tmp.png
''

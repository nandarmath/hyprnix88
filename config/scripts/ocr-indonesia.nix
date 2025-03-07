{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "ocr-indonesia" ''
  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp $SLURP_ARGS)" "tmp.png" && \
  ${pkgs.tesseract}/bin/tesseract --oem 3 -l ind "tmp.png" - | \
  ${pkgs.wl-clipboard}/bin/wl-copy && \
  rm "tmp.png"
''

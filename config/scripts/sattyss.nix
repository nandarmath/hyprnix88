{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "sattyss" ''
  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | \
  ${pkgs.satty}/bin/satty \
    --filename - \
    --fullscreen \
    --output-filename ~/Pictures/Screenshots/satty-$(date +%Y%m%d-%H:%M:%S).png
''

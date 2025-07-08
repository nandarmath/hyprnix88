{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "rofi-zotero";
  version = "0.1.0";

  # Prevent mkDerivation from unpacking the source, as we're directly including the script
  dontUnpack = true;

  # Define build inputs, including Python and any required Python packages
  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
      requests
    ]))
  ];

  # Copy the script to the output directory and make it executable
  installPhase = ''
    mkdir -p $out/bin
    cp ${./rofi-zotero.py} $out/bin/rofi-zotero
    chmod +x $out/bin/rofi-zotero
  '';
}

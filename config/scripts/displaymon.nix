{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "hyprland_display_control";
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
    cp ${./monitor_display.py} $out/bin/hyprDC
    chmod +x $out/bin/hyprDC
  '';
}

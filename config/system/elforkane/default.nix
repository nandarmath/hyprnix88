{ config, pkgs, ... }:

let
  elforkane = pkgs.callPackage ./elforkane.nix {};
in

{
  # ... konfigurasi lainnya ...

  environment.systemPackages = with pkgs; [
    # package lainnya
    elforkane
  ];
}

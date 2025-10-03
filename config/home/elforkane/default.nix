{ config, pkgs, ... }:

let
  elforkane = pkgs.callPackage ./elforkane.nix {};
in

{
  home.packages = [
    elforkane
  ];
}

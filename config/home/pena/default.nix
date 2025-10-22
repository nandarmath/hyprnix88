{ config, pkgs, ... }:

let
  pena = pkgs.callPackage ./pena.nix {};
in

{
  home.packages = [
    pena
  ];
}

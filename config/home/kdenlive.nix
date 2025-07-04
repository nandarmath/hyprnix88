{ pkgs, lib, ... }:

let inherit (import ../../options.nix) kdenlive; in
lib.mkIf (kdenlive == true) {
  home.packages = with pkgs; [
    pkgs.kdePackages.kdenlive
  ];
}

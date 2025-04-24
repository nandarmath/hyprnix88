{ config, lib, pkgs, ... }:

let inherit (import ../../../options.nix) theKernel; in
lib.mkIf (theKernel == "cachyos") {
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
}

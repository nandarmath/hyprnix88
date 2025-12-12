
{ config, lib, pkgs, ... }:

let inherit (import ../../../options.nix) theKernel; in
lib.mkIf (theKernel == "cachyosv2") {
  nixpkgs.overlays =[self.overlay];
  boot.kernelPackages = pkgs.cachyosKernels.linux-cachyos-lates-lto;
}

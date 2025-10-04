{ pkgs, config,lib, ... }:

{
  boot = {
     loader = {
          grub.enable = true;
          grub.devices = "nodev";
          efi.canTouchEfiVariables = true;
          efi.efiSysMountPoint = "/boot";
          grub.efiSupport = true;
          grub.useOSProber = true;
        };      
       #boot.loader.grub.theme = pkgs.nixos-grub2-theme;
       # boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
       #   pname = lib.mkForce "distro-grub-themes";
       #   version =lib.mkForce "3.1";
       #   src = lib.mkForce pkgs.fetchFromGitHub {
       #     owner = "AdisonCavani";
       #     repo = "distro-grub-themes";
       #     rev = "v3.1";
       #     hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
       #   };
       #   installPhase = "cp -r customize/nixos $out";
       # };
     supportedFilesystems =[
      "brtfs"
      "ntfs"
      "fat32"
      "exfat"
      "vfat"
      ];
     plymouth.enable = true;
     
        # This is for OBS Virtual Cam Support - v4l2loopback setup
     kernelModules = [ "v4l2loopback" ];
     extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
     };
}

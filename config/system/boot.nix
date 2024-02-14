{ pkgs, config, ... }:

{
  boot.loader.grub.enable = true;
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  #boot.loader.grub.theme = pkgs.nixos-grub2-theme;
  boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
    pname = "distro-grub-themes";
    version = "3.1";
    src = pkgs.fetchFromGitHub {
      owner = "AdisonCavani";
      repo = "distro-grub-themes";
      rev = "v3.1";
      hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
    };
    installPhase = "cp -r customize/nixos $out";
  };
  boot.supportedFilesystems =[
      "brtfs"
      "ntfs"
      "fat32"
      "exfat"
      "vfat"
  ];
  boot.plymouth.enable = false;

  # This is for OBS Virtual Cam Support - v4l2loopback setup
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
}

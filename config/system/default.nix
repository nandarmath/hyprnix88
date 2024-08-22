{ config, pkgs, ... }:

{
  imports = [
    ./amd-gpu.nix
    ./appimages.nix
    ./autorun.nix
    ./boot.nix
    ./displaymanager.nix
    ./flatpak.nix
    ./hwclock.nix
    ./intel-amd.nix
    ./intel-gpu.nix
    ./intel-nvidia.nix
    ./kernel.nix
    ./logitech.nix
   # ./neovim.nix
    ./nfs.nix
    ./ntp.nix
    ./nvidia.nix
    ./packages.nix
    ./persistence.nix
    ./polkit.nix
    ./python.nix
    ./printer.nix
    ./services.nix
    ./steam.nix
    ./vm.nix
    ./rstudio.nix
    #./docker.nix
    ./obs.nix
    ./power.nix
    ./podman.nix
    #./moodle.nix
    #./kde.nix
    ./google-chrome.nix
    ./moodlev2.nix
    ./apache.nix
  ];
}

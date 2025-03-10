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
    ./fonts.nix
    ./ntp.nix
    ./nvidia.nix
    ./packages.nix
    ./persistence.nix
    ./polkit.nix
    ./python.nix
    ./printer.nix
    ./services.nix
    ./vm.nix
    ./rstudio.nix
    ./obs.nix
    ./power.nix
     ./podman.nix
    ./google-chrome.nix
    ./lemp.nix
    ./gnome.nix
    ./incus.nix
    ./network.nix
    ./nh.nix
    # ./virtualbox.nix
    ./mpd.nix
    # ./espanso.nix
    ./open-webui.nix
    ./mpv.nix
  ];
}

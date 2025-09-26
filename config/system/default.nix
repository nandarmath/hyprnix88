{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./amd-gpu.nix
    ./appimages.nix
    ./autorun.nix
    ./boot.nix
    ./displaymanager.nix
    ./flatpakNew.nix
    ./hwclock.nix
    ./intel-amd.nix
    ./intel-gpu.nix
    ./intel-nvidia.nix
    ./kernel.nix
    ./logitech.nix
    # ./dhcp.nix
    # ./neovim.nix
    ./nfs.nix
    ./fonts.nix
    ./ntp.nix
    ./nvidia.nix
    ./packages.nix
    # ./persistence.nix
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
    ./virtualbox.nix
    # ./espanso.nix
    ./open-webui.nix
    ./mpv.nix
    ./stylix.nix
    inputs.stylix.nixosModules.stylix
    ./syncthing.nix
    ./scheduler2.nix
    ./virtmanager.nix
    ./tlp.nix
    ./espanso
    # ./cloudflared.nix
    # ./collabora.nix
    # ./nixvim/nixvim.nix
  ];
}

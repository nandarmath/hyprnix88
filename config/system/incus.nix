{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.firewall.trustedInterfaces = ["incusbr0"];
  networking.nftables.enable = true;
  environment.systemPackages = with pkgs; [incus];
  virtualisation.incus.enable = true;
}

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-network-displays
    miraclecast

  ];

  # xdg.portal.enable = true;
  #
  # xdg.portal.xdgOpenUsePortal = true;
  # xdg.portal.extraPortals = [
  #   pkgs.xdg-desktop-portal-gnome
  #   pkgs.xdg-desktop-portal-hyprland
  # ];
  #
  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];

  networking.firewall.allowedTCPPorts = [
    7236
    7250
  ];
  networking.firewall.allowedUDPPorts = [
    7236
    5353
  ];
}

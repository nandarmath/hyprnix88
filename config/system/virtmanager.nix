{ pkgs, ... }:
{
  virtualisation = {
    libvirtd.enable = true;
    # libvirtd.allowedBridges = [ "virbr0" ];
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    virt-viewer
    libvirt
    libvirt-glib
  ];

}

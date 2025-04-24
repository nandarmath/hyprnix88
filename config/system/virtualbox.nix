{config, pkgs, ...}:
{
virtualisation.virtualbox = {
    host = {
      enable = true;
      package = pkgs.virtualbox;
      enableExtensionPack = false;
    };
    guest.enable = false;
    guest.clipboard = true;
  };
}

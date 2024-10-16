{config, pkgs, ...}:
{
virtualisation.virtualbox = {
    host = {
      enable = true;
      package = pkgs.virtualbox;
      enableExtensionPack = true;
    };
    guest.enable = true;
    guest.clipboard = true;
  };
}

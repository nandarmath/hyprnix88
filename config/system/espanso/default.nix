{ pkgs, config, ... }:
{
  services.espanso = {
    package = pkgs.espanso-wayland;
    enable = true;
  };

}

{ config, pkgs, ... }:

{
  # Enable fingerprint scanner
  services.fprintd = {
    enable = true;
    tod.enable = true;
    package = if config.services.fprintd.tod.enable then pkgs.fprintd-tod else pkgs.fprintd;
    tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
  };
  hardware.libfprint.enable = true;
}

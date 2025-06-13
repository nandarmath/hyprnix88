{ pkgs, lib, config, ... }:
{
services.desktopManager.plasma6 = {
  enable = true;
  enableQt5Integration = true;
  };

environment.plasma6.excludePackages = with pkgs; [
  gwenview
  elisa
  konsole
  dolphin
  spectacle
  ark
  orca

  ];






}

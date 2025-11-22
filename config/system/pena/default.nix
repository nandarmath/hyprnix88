{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    (callPackage ./pena.nix { })
  ];

}

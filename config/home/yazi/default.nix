{ pkgs, ... }:
{
  home.file = {
    ".config/yazi" = {
      source = ../yazi;
      recursive = true;
    };
  };
  home.packages = with pkgs; [
    yazi
  ];
}

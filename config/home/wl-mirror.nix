{ pkgs, ... }:
{
  home.packages = with pkgs;[
    wl-mirror
  ];

  home.file."~/.config/wl-mirror/scripts" =

}

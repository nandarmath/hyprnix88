{
  pkgs,
  config,
  ...
}: let
  inherit
    (import ../../options.nix)
    waybarChoice
    ;
in {
  imports = [
    # Enable &/ Configure Programs
    ./alacritty.nix
    ./bash.nix
    ./gtk-qt.nix
    ./hyprland
    ./kdenlive.nix
    ./kitty.nix
    ./packages.nix
    ./rofiw.nix
    ./starship.nix
    waybarChoice
    ./swappy.nix
    ./swaync.nix
    ./swayosd.nix
    ./wezterm.nix
    ./zsh.nix
    ./fish.nix
    ./tex.nix
    ./fonts.nix
    ./wlogout
    ./yazi
    ./files.nix
    # ./firefox.nix
    ./fastfetch
    ./cava.nix
    ./mpd.nix
    ./vim.nix
    ./stylix.nix
    ./zed.nix
    # ./dashboard
    ../scripts/scripts.nix
    ./eww-treanto
    # ./walker.nix
    # ./anyrun.nix
    ./nxchad.nix
    ./rmpc
    # ./hypr-dock.nix


  ];
}

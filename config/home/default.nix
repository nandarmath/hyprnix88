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
    ./rofi.nix
    # ./rofi
    ./starship.nix
    # ./waybar.nix
    waybarChoice
    ./swappy.nix
    ./swaylock.nix
    ./swaync.nix
    ./wezterm.nix
    ./zsh.nix
    ./fish.nix
    ./tex.nix
    ./fonts.nix
    ./wlogout.nix
    ./yazi
    ./files.nix
    ./firefox.nix
    ./fastfetch
    ./cava.nix
    ./mpd.nix
    ./ncmpcpp.nix
    ./vim.nix
    ./stylix.nix
    ./nvf.nix
    ./zed.nix
    # ./eww
    # ./nixvim.nix
    # ./espanso.nix
  ];
}

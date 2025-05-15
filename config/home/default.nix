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
    # ./niri
    ./kdenlive.nix
    ./kitty.nix
    ./packages.nix
    ./rofi.nix
    # ./rofi
    ./starship.nix
    waybarChoice
    ./swappy.nix
    # ./swaylock.nix
    ./swaync.nix
    ./wezterm.nix
    ./zsh.nix
    ./fish.nix
    ./tex.nix
    ./fonts.nix
    ./wlogout
    ./yazi
    ./files.nix
    ./firefox.nix
    ./fastfetch
    ./cava.nix
    ./mpd.nix
    ./ncmpcpp.nix
    ./vim.nix
    ./stylix.nix
    # ./nvf.nix
    # ./neovim
    # ./nvf.nix
    # ./nxchad.nix
    ./zed.nix
    ./dashboard
    # ../home/waybar/prayer_time_notif.nix


    # ./eww
    # ./nixvim.nix
    # ./espanso.nix
  ];
}

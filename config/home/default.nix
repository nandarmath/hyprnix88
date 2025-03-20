{ pkgs, config, ... }:

{
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
    ./starship.nix
    ./waybar.nix
    ./swappy.nix
    ./swaylock.nix
    ./swaync.nix
    ./wezterm.nix
    ./zsh.nix
    ./fish.nix
    ./tex.nix
    ./fonts.nix
    ./wlogout.nix
    ./yazi.nix
    ./files.nix
    ./firefox.nix
    ./fastfetch
    ./cava.nix
    ./mpd.nix
    ./ncmpcpp.nix
    ./vim.nix
    # ./espanso.nix
  ];
}

{ pkgs, config, ... }:

{
  imports = [
    # Enable &/ Configure Programs
    ./alacritty.nix
    ./bash.nix
    ./gtk-qt.nix
    ./hyprland.nix
    ./kdenlive.nix
    ./kitty.nix
    ./neofetch.nix
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
    #./kde.nix
    #./neovim.nix
    # Place Home Files Like Pictures
    ./files.nix
    # ./nvim.nix
    ./cava.nix
  ];
}

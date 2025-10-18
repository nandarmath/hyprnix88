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
    ./rofiwf.nix
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
    ./files.nix
    ./fastfetch
    ./cava.nix
    ./mpd.nix
    ./vim.nix
    ./stylix.nix
    ./zed.nix
    ../scripts/scripts.nix
    ../scripts/scripts-sh.nix
    ./eww-treanto
    ./nxchad.nix
    ./rmpc
    ./xdg-mime.nix
    ./xdg.nix
    ./yazi
    ./keepasxc.nix
    ./espanso
    ./elforkane
    ./vicinae/vicinae.nix
    # ./nstv.nix
    # ./yazi.nix


  ];
}

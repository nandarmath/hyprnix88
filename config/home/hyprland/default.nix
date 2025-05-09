{...}: let
  inherit (import ../../../options.nix) animChoice;
in {
  imports = [
    animChoice
    ./binds.nix
    ./config.nix
    ./hypridle.nix
    ./hyprland.nix
    ./pyprland.nix
    ./hyprexpo.nix
    ./hyprgrass.nix
    ./hyprlock.nix
  ];
}

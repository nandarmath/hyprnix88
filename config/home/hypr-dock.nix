{ config, pkgs, ... }:

let
  hypr-dock = import ../pkgs/hypr-dock { inherit pkgs; };
in {
  # Konfigurasi lainnya...
  
  home.packages = with pkgs; [
    # Paket lainnya...
    hypr-dock
  ];

  home.file.".config/hypr-dock/themes" = { 
            recursive = true;
            source = ../pkgs/hypr-dock/themes;
        };

  home.file.".config/hypr-dock/config.jsonc".source = ../pkgs/hypr-dock/config.jsonc;
  home.file.".config/hypr-dock/pinned.json".source = ../pkgs/hypr-dock/pinned.json;

}

{ config, pkgs,... }:
{
  # Tambahkan ke paket home-manager
  home.packages = 
  let 
  hypr-dock = pkgs.callPackage ../pkgs/hypr-dock {};
  in [
    # Paket lainnya...
    hypr-dock
  ];
  home.file.".config/hypr-dock/themes" = { 
            recursive = true;
            source = ../pkgs/hypr-dock/themes;
        };

  home.file.".config/hypr-dock/config.jsonc".source = ../pkgs/hypr-dock/config.jsonc;
  # home.file.".config/hypr-dock/pinned.json".source = ../pkgs/hypr-dock/pinned.json;

}

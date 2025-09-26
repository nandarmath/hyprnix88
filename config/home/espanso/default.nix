{ pkgs, config, ... }:
{

  home.file.".config/espanso/config/default.yml".source = ./default.yml;
  home.file.".config/espanso/match/base.yml".source = ./base.yml;

}

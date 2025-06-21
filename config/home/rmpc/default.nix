
{ inputs, lib, config, pkgs, ... }:
 {

        # theres no programs.eww.enable here because eww looks for files in .config
        # thats why we have all the home.files

        # eww package
        home.packages = with pkgs; [
          rmpc
            # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        # configuration
        home.file.".config/rmpc/themes/" = { 
            recursive = true;
            source = ../rmpc/themes;
        };
        home.file.".config/rmpc/config.ron".source = ./config.ron;
        home.file.".config/rmpc/notify".source = ./notify;
        # home.file.".config/eww/scripts/weather_info" = {
        #     source = ./scripts/weather_info;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/open_folders" = {
        #     source = ./scripts/open_folders;
        #     executable = true;
        # };
 }


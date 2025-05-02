
{ inputs, lib, config, pkgs, ... }:
 {

        # theres no programs.eww.enable here because eww looks for files in .config
        # thats why we have all the home.files

        # eww package
        home.packages = with pkgs; [
            eww
            pamixer
            brightnessctl
            # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        # configuration
        home.file.".config/eww/dashboard/images/" = { 
            recursive = true;
            source = ./images;
        };
        home.file.".config/eww/dashboard/eww.scss".source = ./eww.scss;
        home.file.".config/eww/dashboard/eww.yuck".source = ./eww.yuck;
        home.file.".local/share/fonts/feather.ttf".source = ./feather.ttf;
        home.file.".config/eww/dashboard/launch_dashboard" = {
            source = ./launch_dashboard;
            executable = true;
        };

        home.file.".config/eww/dashboard/scripts/" = {
            recursive = true;
            source = ./scripts;
            executable = true;
        };
        # home.file.".config/eww/scripts/mails" = {
        #     source = ./scripts/mails;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/musisc_info" = {
        #     source = ./scripts/music_info;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/open_apps" = {
        #     source = ./scripts/open_apps;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/open_links" = {
        #     source = ./scripts/open_links;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/sys_info" = {
        #     source = ./scripts/sys_info;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/weather_info" = {
        #     source = ./scripts/weather_info;
        #     executable = true;
        # };
        # home.file.".config/eww/scripts/open_folders" = {
        #     source = ./scripts/open_folders;
        #     executable = true;
        # };
 }

{
  pkgs,
  ...
}: {
  # terminal file manager
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    # Changing working directory when exiting Yazi
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    settings={
     #opener = {
     #  edit = [
	   #    { run = 'nvim "$@"', block = true },
     #  ];
     #  play = [
	   #    { run = 'mpv "$@"', orphan = true, for = "unix" },
     #  ];
     #  open = [
	   #    { run = 'xdg-open "$@"', desc = "Open" },
     #  ];
     #};
    };
   #keymap = {
   #  cd.keymap = [
   #     # { exec = "cd ~/Data/01 My Data/01 Kuliah"; on =["g","k"];}
   #     ## { exec = "cd ~/Data/01 My Data"; on =["g","m"];}
   #   ]
   #}
  };

  #xdg.configFile."yazi/theme.toml".source = "${pkgs.system}.catppuccin-yazi}/mocha.toml";
}

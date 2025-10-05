{ inputs, ... }:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];

  services.vicinae = {
    enable = true;
    autoStart = true;
    settings = {
      faviconService = "twenty"; # twenty | google | none
      font.size = 11;
      popToRootOnClose = false;
      rootSearch.searchFiles = true;
      theme.name = "vicinae-dark";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
   };
  };

  # xdg.configFile."vicinae/vicinae.json".source = ./vicinae.json;
  # xdg.configFile."vicinae/themes/gruvbox-dark-hard.json".source = ./gruvbox-dark-hard.json;
}

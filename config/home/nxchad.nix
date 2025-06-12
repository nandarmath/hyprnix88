{pkgs, ...}:{


programs.nixvim = {
  enable = true;
  plugins.cmp-path.enable = true;
  plugins.cmp-path.autoLoad = true;
  };
programs.nixvim = {
          # change theme nvchad
  nvchad.config.base46.theme = "starlight";
  };




}

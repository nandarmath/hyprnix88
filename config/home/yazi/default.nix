{pkgs, ...}:{
  home.file = {
    ".config/yazi" = {
      source = ../yazi;
      recursive = true;
    };
  };
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
  };
}

{pkgs, ...}: {
  services.teamviewer = {
    enable = true;
    package = pkgs.teamviewer;
  };
}

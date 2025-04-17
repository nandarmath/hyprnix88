{pkgs, ...}: {
  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    user = "nandar";
    group = "users";
    dataDir = "/home/nandar/Documents";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      options = {
        localAnnounceEnabled =false;
        urAccepted = -1;
      };
      devices = {
        "note30" = {
          id = "LYMJS3B-ADO2IY3-UKCCYEF-X2GEEYU-A5I4GYL-IE54JMZ-T3NXSNH-FW3BXQQ";
        };
      };
      folders = {
        "KeepassDb" = {
          path = "~/Documents/KeepPassdb";
          devices = ["note30"];
        };
        "Sync" = {
          path = "~/Documents/Sync";
          devices = ["note30"];
        };
      };
    };
  };
}

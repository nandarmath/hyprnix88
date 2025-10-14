{ pkgs, config, ... }:
{

  services.samba = {
    enable = true;
    settings = {
      "public" = {
        "path" = "/home/nandar/share";
        "read only" = "no";
        "browseable" = "yes";
        "guest ok" = "yes";
        "comment" = "Public samba share.";
      };
      "global" = {
        "server min protocol" = "NT1";
      };
    };
  };

}

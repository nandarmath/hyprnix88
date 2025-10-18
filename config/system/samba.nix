{ pkgs, config, ... }:
{

  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    package = pkgs.samba4Full;
    settings = {
      "global" = {
        "workgroup" = "WORKGROUP";
        "server string" = "NIXLAPTOP";
        "netbios name" = "NIXLAPTOP";
        "client min protocol" = "SMB2";
        "server min protocol" = "SMB3";
      };
      "public" = {
        "path" = "/home/nandar/share";
        "read only" = "no";
        "browseable" = "yes";
        "guest ok" = "yes";
        "comment" = "Public samba share.";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  networking.firewall.allowedTCPPorts = [139 445];
  networking.firewall.allowedUDPPorts = [137 138];
}

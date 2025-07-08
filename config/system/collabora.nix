{ pkgs, ... }:
{
  services.collabora-online = {
    enable = true;
    package = pkgs.collabora-online;
    port = 9980;
    settings = {
      net = {
        listen = "loopback";
        post_allow.host = [ "::1" ];
      };
    };
  };
}

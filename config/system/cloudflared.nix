{ config, inputs, lib, modulesPath, pkgs, ... }:
let inherit (config.sops.secrets) tunnel-credentials; in
{
  # imports = [
  #   inputs.sops-nix.nixosModules.default
  # ];

  # sops.secrets.tunnel-credentials = {
  #   owner = "cloudflared";
  #   group = "cloudflared";
  #   name = "tunnel-credentials.json";
  #   format = "binary";
  #   sopsFile = ../sops/builder/tunnel-credentials;
  # };

  services = {
    cloudflared = {
      user = "cloudflared";
      group = "cloudflared";
      enable = true;
      package = pkgs.cloudflared;
      tunnels = {
        "dbc10dfa-c569-4562-a0f3-51b5ad9b8b72" ={
          credentialsFile = "./secret/dbc10dfa-c569-4562-a0f3-51b5ad9b8b72.json";
          default = "http_status:404";
          ingress = {
            "lms1.riastri.com".service= "http://localhost:82";
            "lms2.riastri.com".service="http://localhost:81";
          };
        };
        # "ee62e85b-6edf-4715-a466-7962b24b3ec7" ={
        #   credentialsFile = "/home/nandar/.cloudflared/ee62e85b-6edf-4715-a466-7962b24b3ec7.json";
        #   default = "http_status:404";
        #   ingress = {
        #     "lms2.riastri.com" = {
        #     service = "http://localhost:81";
        #     };
        #   };
        # };
      };
    };
  };
}

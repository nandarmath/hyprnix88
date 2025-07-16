{
  pkgs,
  ...
}:
{
  services = {
    cloudflared = {
      enable = true;
      package = pkgs.cloudflared;
      tunnels = {
        "dbc10dfa-c569-4562-a0f3-51b5ad9b8b72" = {
          credentialsFile = "/etc/cloudflared/dbc10dfa-c569-4562-a0f3-51b5ad9b8b72.json";
          default = "http_status:404";
          originRequest.noTLSVerify = true;
          ingress = {
            "elmim.riastri.com".service = "http://localhost";
            "rstudio.riastri.com".service = "http://localhost:8787";
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

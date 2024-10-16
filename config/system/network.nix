{config, pkgs,...}:
{
  networking = {
    wg-quick.interfaces = {
      wg0={
        address =["10.2.0.2/32"];
        dns = ["10.2.0.1"];
        privateKey ="qMPBwLqo33vBPwrU1icX3WCzFGjso6pCgq9XDYLYOVI=";
        peers=[{
          publicKey ="mortbpQLtauCXw+rSFfEty9xZa1kEAeB9iB/c8sw6Wo=";
          allowedIPs =["0.0.0.0/0"];
          endpoint="212.102.51.110:51820";
        }];
      };
    };
  };



}

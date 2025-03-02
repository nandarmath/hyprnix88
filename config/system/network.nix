{config, pkgs,...}:
{
  networking = {
    wg-quick.interfaces = {
      wg0={
        address =["10.2.0.2/32"];
        dns = ["10.2.0.1"];
        privateKey ="QBLS8ID/8U+7m+kv1ylScfwBzmd3JxYQVrGAn1WM4n0=";
        peers=[{
          publicKey ="xrZTJ9U7GHo834PN1sckR4RuLjP/Sy0jb2d0z1pLgzU=";
          allowedIPs =["0.0.0.0/0"];
          endpoint="37.19.205.198:51820";
        }];
      };
    };
  };



}

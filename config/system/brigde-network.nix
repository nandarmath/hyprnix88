{config, pkgs,...}:
{
networking = {
  interfaces.enp3s0.useDHCP = false;

  bridges.br0 = {
    interfaces = [ "enp3s0" ];
    useDHCP = false;
    ipv4.addresses = [ { address = "192.168.1.1"; prefixLength = 24; } ];
    ipv4.gateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
};



}

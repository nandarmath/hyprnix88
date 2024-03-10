{ config, lib, pkgs, username, storageDriver ? null, ...}:
#assert lib.asserts.assertOneOf "storageDriver" storageDriver [
# null
# "aufs"
# "ext4"
# "devicemapper"
# "overlay"
# "overlay2"
# "zfs"
#;
#
{
  virtualisation.docker = {
    enable = false;
    enableOnBoot = true;
    #inherit storageDriver;
    autoPrune.enable = true;
  };
  environment.systemPackages = with pkgs;[
    docker-compose
  ];
  users.users.${username}.extraGroups = [ "docker" ];
}

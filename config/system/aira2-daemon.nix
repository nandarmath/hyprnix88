{pkgs, ...}:
{
systemd.user.services.aria2-daemon = {
    description = "Aria2 RPC Daemon";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.aria2}/bin/aria2c --enable-rpc --rpc-listen-all=false --rpc-listen-port=6800 --continue=true --max-connection-per-server=16 --min-split-size=1M --split=16 --max-concurrent-downloads=5";
      Restart = "on-failure";
    };
  };
}

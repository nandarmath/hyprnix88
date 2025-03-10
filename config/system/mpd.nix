{ pkgs, config, ...}:
{

services.mpd = {
  enable = true;
  user ="nandar";
  group = "users";
  musicDirectory = "/home/nandar/Music/";
  extraConfig = ''
   audio_output {
    type "pipewire"
    name "My PipeWire Output"
  }
    # must specify one or more outputs in order to play audio!
    # (e.g. ALSA, PulseAudio, PipeWire), see next sections
  '';
  network.listenAddress = "127.0.0.1";

  # Optional:
  # network.listenAddress = "any"; # if you want to allow non-localhost connections
  # network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
};

  environment.systemPackages = with pkgs; [
    mpc_cli
  ];



}

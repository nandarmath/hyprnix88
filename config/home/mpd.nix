{ pkgs, config, ...}:
{
    services.mpd = {
      enable = true;
      musicDirectory = "/home/nandar/Music";
      extraConfig = ''
            auto_update    "yes"
            restore_paused "yes"
            audio_output {
              type         "pipewire"
              name         "pipewire-output"
            }
            audio_output {
              type         "fifo"
              name         "visualizer"
              format       "44100:16:2"
              path         "/tmp/mpd.fifo"
            }
          '';
    };
    services.mpd-mpris ={
      enable = true;
    };

    services.playerctld.enable = true;

  home.packages = with pkgs; [
    mpc_cli
    playerctl
    ncmpcpp
  ];

}

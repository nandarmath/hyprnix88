{pkgs, ...}: {
  programs = {
    ncmpcpp = {
      enable = true;
      bindings = [
        {
          key = "j";
          command = ["scroll_down"];
        }
        {
          key = "k";
          command = ["scroll_up"];
        }
        {
          key = "J";
          command = ["select_item" "scroll_down"];
        }
        {
          key = "K";
          command = ["select_item" "scroll_up"];
        }
      ];
      mpdMusicDir = "~/Music/Mp3";
      settings = {
        mpd_host = "localhost";
        # mpd_music_dir = "/home/nandar/Music";
        mpd_port = "6600";
        autocenter_mode = "yes";
        centered_cursor = "yes";
        external_editor = "nvim";
        header_visibility = "no";
        ignore_leading_the = true;
        main_window_color = "blue";
        message_delay_time = 1;
        playlist_disable_highlight_delay = 2;
        progressbar_color = "black";
        progressbar_elapsed_color = "blue";
        progressbar_look = "━━━";
        statusbar_visibility = "no";
        titles_visibility = "no";
        user_interface = "alternative";
        visualizer_color = "blue, green";
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_look = "●●";
        visualizer_output_name = "mpd-visualizer";
        visualizer_type = "ellipse";
      };
    };
  };
}

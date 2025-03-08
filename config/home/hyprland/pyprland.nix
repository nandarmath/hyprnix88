{pkgs, ...}: {
  home.packages = with pkgs; [pyprland];

  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
    ]

    [scratchpads.term]
    animation = "fromTop"
    command = "kitty --class kitty-dropterm"
    class = "kitty-dropterm"
    size = "75% 60%"
    max_size = "1920px 100%"

    [scratchpads.calendar]
    animation = "fromTop"
    command = "kitty -e calcure"
    class = "kitty-dropterm"
    lazy = true
    size = "40% 60%"

    [scratchpads.thunar]
    animation = "fromBottom"
    command = "thunar"
    class = "thunar"
    size = "75% 60%"
  '';
}


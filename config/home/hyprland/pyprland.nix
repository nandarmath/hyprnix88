{pkgs, ...}: {
  home.packages = with pkgs; [pyprland];

  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
      "magnify",
      "expose",
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
    class = "calcure"
    lazy = true
    size = "40% 60%"

    [scratchpads.nautilus]
    animation = "fromBottom"
    command = "nautilus"
    class = "nautilus"
    size = "75% 60%"
  '';
}


{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "wl-recordNoA" ''
  #!/usr/bin/env bash
  wl-screenrec -g "$(slurp)" --filename=$HOME/Videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
''

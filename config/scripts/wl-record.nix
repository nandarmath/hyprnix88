{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "wl-record" ''
  #!/usr/bin/env bash
  wl-screenrec -g "$(slurp)" --audio --filename=$HOME/Videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
''

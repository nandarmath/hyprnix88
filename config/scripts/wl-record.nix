{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "wl-record" ''
  #!/usr/bin/env bash
  wl-screenrec -g "$(slurp)" --audio --audio-device  "NoiseTorch Microphone for Built-in Audio" --filename=$HOME/Videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
''

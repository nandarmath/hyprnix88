{pkgs ? import <nixpkgs> {}}:
pkgs.writeScriptBin "wl-record" ''
  #!/usr/bin/env bash
  wl-screenrec -g "$(slurp)" --audio --audio-device alsa_input.pci-0000_00_1f.3.analog-stereo --filename=$HOME/Videos/$(date +Rec%d%m%Y_%Hh%Mm%Ss.mp4)
''

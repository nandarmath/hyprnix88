{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (import ../../options.nix) python;
  my-python-packages = ps:
    with ps; [
      pandas
      requests
      jupyter
      numpy
      scipy
      spyder
      matplotlib
      statsmodels
      seaborn
      pyreadstat
      markdown
      pulp
      pip
      sympy
      scikit-learn
      typing
      plotly
      tinycss2
      # speechrecognition
      pydub
      # pyside2
      torch
      whisper
      srt
      tqdm
      google-api-python-client
      google-auth-httplib2
      google-auth-oauthlib
      pygobject3
      pycairo
      configparser
      dbus-python
    ];
in
  lib.mkIf (python == true) {
    environment.systemPackages = [
      #jetbrains.pycharm-community-bin
      (pkgs.python3.withPackages my-python-packages)
    ];
  }

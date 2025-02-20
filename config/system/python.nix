{ pkgs, config, lib, ... }:

let
  inherit (import ../../options.nix) python;
  my-python-packages = ps: with ps; [
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
    # whisper



  ];
in lib.mkIf (python == true) {
  environment.systemPackages = with pkgs; [
    #jetbrains.pycharm-community-bin
    (pkgs.python3.withPackages my-python-packages)
  ];

}

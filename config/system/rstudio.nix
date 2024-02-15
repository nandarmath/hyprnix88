{ pkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs;let
    list-packages = with rPackages;[
      quarto
       AER
       Amelia
       AmesHousing
       BB
       BBmisc
       BH
       BatchJobs
       BiasedUrn
       BoolNet
       BradleyTerry2
       Brobdingnag
       CVST
       Cairo
       CircStats
       ClustVarLV
       Cubist
       DAAG
       DBI
       DBItest
       DEoptim
       DEoptimR
       DRR
       DT
       DendSer
       Deriv
       DescTools
       DistributionUtils
       DoseFinding
       EnvStats
       FMStable
       FNN
       Fahrmeir
       Formula
       GGally
       GPArotation
       GeneralizedHyperbolic
       GlobalOptions
       HistData
       Hmisc
       readODS
      readr
      readstata13
      readxl
      recipes
      registry
      relimp
      rematch
      rematch2
      remote
      plm
      plogr
      plotly
      plotmo
      plyr
      pmml
      png
      poLCA
      polspline
      polyCub
      polyclip
      polycor
      polynom
      prabclus
      pracma

  ];
      r-with-packages =
          (
            rWrapper.override {
              packages = list-packages;
            }
          );
          rstudio-with-packages =
          (
            rstudioWrapper.override {
              packages = list-packages;
            }
          );
        in [
          r-with-packages
          rstudio-with-packages
        ];


}


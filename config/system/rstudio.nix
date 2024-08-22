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
      # Tamabahan
      r2spss
      MultivariateAnalysis
      RVAideMemoire
      mvnormtest
      BART
      factoextra
      pandoc
      markdown
      FactoMineR
      tidyverse
      ggimage
      Hotelling
      psych
      MCMCpack
      pastecs
      doBy
      ICSNP
      scales
      gt
      webr
      Morpho
      MVN
      agricolae
      here
      knitr
      tidytext
      kableExtra
      ggthemes
      ggdag
      textclean
      wordcloud
      colourpicker
      esquisse
      httr2
      sf
      leaflet
      rvest
      forcats
      stringr
      purrr
      meta
      metafor
      tidyr
      devtools
      jmv
      shiny
      RColorBrewer
      raster
      sf
      sp
      #ggsn
      dbscan
      #rgdal
      spatialreg
      spatial
      mapview
      tidyselect
      ggvenn
      
      

      









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


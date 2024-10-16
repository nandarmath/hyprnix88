{config, pkgs, ...}:
{

# environment.systemPackages = [ pkgs.rstudio-server];
services.rstudio-server ={
  enable = true;
  # serverWorkingDir = "/home/$USER/";
  listenAddr = "0.0.0.0";
  package = pkgs.rstudioServerWrapper.override {
      packages = with pkgs.rPackages; [
        languageserver
        tidyverse
        caret
        ggplot2
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
       rmarkdown
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
      dbscan
      #rgdal
      spatialreg
      spatial
      mapview
      tidyselect
      ggvenn
      CTT
      ltm
      psychometric
      eRm
      difR
      MASS
      
      ];
  };
};

 systemd.services.rstudio-server = {
    path = [
      pkgs.git
      pkgs.zip
    ];
  };




}

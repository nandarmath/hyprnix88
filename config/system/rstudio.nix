{ pkgs, ... }:
with pkgs;
let
  # name = "nandar";
  list-packages = with rPackages; [
    AER
    Amelia
    AmesHousing
    BB
    BBmisc
    BH
    BatchJobs
    gtExtras
    gtsummary
    BiasedUrn
    janitor
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
    # DescTools
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
    tinytex
    readstata13
    readxl
    recipes
    registry
    relimp
    rematch
    rematch2
    RPostgreSQL
    # remote
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
    MASS
    caret
    FactoMineR
    tidyverse
    tidyxl
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
    # Morpho
    MVN
    rjson
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
    # leaflet
    rvest
    forcats
    stringr
    purrr
    meta
    metafor
    tidyr
    devtools
    # jmv
    shiny
    RColorBrewer
    # raster
    sf
    sp
    #ggsn
    dbscan
    #rgdal
    spatialreg
    spatial
    # mapview
    tidyselect
    ggvenn
    ggvis
    rpivotTable
    highcharter
    CTT
    ltm
    psychometric
    eRm
    # difR
    gapminder
    ggforce
    gh
    globals
    # openintro
    profvis
    RSQLite
    shinycssloaders
    shinyFeedback
    shinythemes
    shinydashboard
    # testthat
    thematic
    vroom
    waiter
    xml2
    zeallot
    shinylive
    shinyquiz
    bslib
    bsicons
    quarto
    bibliometrix
    naniar
    bibliometrixData
    # rcrossref
    tm
    SnowballC
    topicmodels
    igraph
    quanteda_textstats
    quanteda
    ggraph
    chromote
    # websocket
    # webshot2
    RCurl
    svSweave
    wordcloud2
    # rtweet    ## broken packages
    ggmap
    visNetwork
    fresh
    shinydashboardPlus
    xfun
    bookdown
    servr
    pagedown
    sparkline
    countdown
    equatiomatic
    car
    moments
    nortest
    reactable # paket untuk inteaktife tabel
    reactablefmtr
    htmltools
    ggiraph
    googlesheets4
    randomForest
    npmv
    vegan
    modeest
    flexdashboard
    hflights
    nycflights13
    broom_helpers
    cardx
    # citr
  ];
in
{
  services = {
    rstudio-server = {
      enable = true;
      listenAddr = "0.0.0.0";
      package = rstudioServerWrapper.override {
        packages = list-packages;
      };
      rsessionExtraConfig = "copilot-enabled=1";
    };
  };
  environment = {
    systemPackages =
      let
        r-with-packages = (
          rWrapper.override {
            packages = list-packages;
          }
        );
        rstudio-with-packages = (
          rstudioWrapper.override {
            packages = list-packages;
          }
        );
      in
      [
        r-with-packages
        rstudio-with-packages
        rnew.positron-bin
      ];
  };
}

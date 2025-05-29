{
  pkgs,
  ...
}:
{
        home = {
        packages = with pkgs;
        with libsForQt5; [
        (texlive.combine { inherit (texlive)
          amsmath
          capt-of
          dvipng
          caption
          tikz-ext
          multirow
          pgf
          inputenx
          setspace
          float
          cancel
          babel
          enumitem
          cite
          natbib
          biblatex
          listings
          xcolor
          cleveref
          pslatex
          tocloft
          sectsty
          geometry
          ragged2e
          pgfplots
          dvisvgm
          moodle
          graphics
          framed
          collection-langother
          hyperref
          ifmtarg
          paralist
          scheme-medium
          titlesec
          ulem
          pdfpages
          wrapfig
          anyfontsize
          xifthen;
        })
        texstudio
        ];
      };

}

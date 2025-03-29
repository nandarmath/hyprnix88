{ appimageTools, fetchurl, ... }:

let
  pname = "lumi";
  version = "0.9.4";

  src = fetchurl {
    url = "https://github.com/Lumieducation/Lumi/releases/download/v${version}/Lumi-${version}.AppImage";
    sha256 = "fc4db27bb08f9e49ae1c04c87e647a84f4d3840499beecdf159d3c1d711e2e5e";
  };

  appimageContents = appimageTools.extract { 
    inherit pname version src; 
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;
  
  extraPkgs = pkgs:[pkgs.at-spi2-core];

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname} 
    install -m 444 -D ${appimageContents}/Lumi.desktop $out/share/applications/${pname}.desktop

    install -m 444 -D ${appimageContents}/${pname}.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    substituteInPlace $out/share/applications/${pname}.desktop \
    	--replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';

}

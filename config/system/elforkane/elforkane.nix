{ lib
, stdenv
, fetchFromGitHub
, qt5
}:

stdenv.mkDerivation rec {
  pname = "elforkane";
  version = "v25.01";

  src = fetchFromGitHub {
    owner = "nandarmath";
    repo = "elforkane";
    rev = "master";
    sha256 = fakesh256;
    # sha256 = "sha256-1u78RuukpNH2xP4rTk95iJ8nR1QqNo0k0LYdsqf3lK0=";
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtmultimedia
  ];

  # Fase konfigurasi menggunakan qmake
  configurePhase = ''
    runHook preConfigure
    qmake PREFIX=$out elforkane.pro
    runHook postConfigure
  '';

  # Fase build
  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  # Fase instalasi
  installPhase = ''
    runHook preInstall
    make install INSTALL_ROOT=$out
    
    # Pastikan direktori yang diperlukan ada
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons
    
    # Jika binary ada di lokasi lain, pindahkan ke $out/bin
    if [ -f $out/usr/bin/elforkane ]; then
      mv $out/usr/bin/elforkane $out/bin/
    fi
    
    # Pindahkan file desktop jika ada
    if [ -f $out/usr/share/applications/elforkane.desktop ]; then
      mv $out/usr/share/applications/elforkane.desktop $out/share/applications/
    fi
    
    # Pindahkan ikon jika ada
    if [ -d $out/usr/share/icons ]; then
      cp -r $out/usr/share/icons/* $out/share/icons/ || true
    fi
    
    # Pindahkan data aplikasi jika ada
    if [ -d $out/usr/share/elforkane ]; then
      mkdir -p $out/share/elforkane
      cp -r $out/usr/share/elforkane/* $out/share/elforkane/ || true
    fi
    
    # Bersihkan direktori /usr yang tidak diperlukan
    rm -rf $out/usr || true
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "The electronic Holy Quran browser Elforkane";
    longDescription = ''
      Elforkane is an electronic Quran reader application built with Qt.
      It provides a beautiful interface for reading and browsing the Holy Quran
      with support for multiple reciters and translations.
    '';
    homepage = "https://github.com/zakariakov/elforkane";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "elforkane";
  };
}

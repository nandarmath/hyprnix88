{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, yad
, imagemagick
, parallel
, pngquant
, bash
, ...
}:

stdenv.mkDerivation rec {
  pname = "pasopati";
  version = "1.9.7";

  src = fetchFromGitHub {
    owner = "raniaamina";
    repo = "pasopati";
    rev = "v${version}";
    # Anda perlu menambahkan hash yang sesuai setelah melakukan fetch
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bash
    yad
    imagemagick
    parallel
    pngquant
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp pasopati $out/bin/
    chmod +x $out/bin/pasopati

    mkdir -p $out/opt/pasopati
    cp pasopati.png $out/opt/pasopati/

    wrapProgram $out/bin/pasopati \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --set PASOPATI_ICON $out/opt/pasopati/pasopati.png
  '';

  meta = with lib; {
    description = "Bulk image resizer tool by Devlovers ID";
    homepage = "https://github.com/raniaamina/pasopati";
    license = licenses.gpl3; # Pastikan untuk mengecek lisensi yang sebenarnya
    platforms = platforms.linux;
    maintainers = with maintainers; [ /* tambahkan maintainer jika perlu */ ];
  };
}

{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt5
, qtbase
, qtmultimedia
, qtwebengine
, sqlite
}:

stdenv.mkDerivation rec {
  pname = "elforkane";
  version = "1.2"; # Sesuaikan dengan versi terbaru di repository

  src = fetchFromGitHub {
    owner = "zakariakov";
    repo = "elforkane";
    rev = "f43f661ad5415d2dce53f8a1fcbededf51a954f8"; # Anda mungkin ingin mengganti dengan tag spesifik
    sha256 = "sha256-1u78RuukpNH2xP4rTk95iJ8nR1QqNo0k0LYdsqf3lK0="; # Gunakan ini saat pertama kali, nanti ganti dengan hash aktual
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qt5.full
    qtbase
    qtmultimedia
    qtwebengine
    sqlite
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Islamic application for reading and studying the Quran";
    homepage = "https://github.com/zakariakov/elforkane";
    license = licenses.gpl3; # Sesuaikan dengan lisensi aktual di repository
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Tambahkan maintainer jika Anda mau
  };
}

{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, rofi
, libxcb
, cairo
, pango
, glib
}:

rustPlatform.buildRustPackage rec {
  pname = "rofi-blocks";
  version = "0.1.0"; # Sesuaikan dengan versi terbaru di repository

  src = fetchFromGitHub {
    owner = "OmarCastro";
    repo = "rofi-blocks";
    rev = "v${version}"; # Pastikan ini sesuai tag di repository
    sha256 = "sha256-jO1NeycBo/nl0DVfgXo5P4xU3cwZCX8KMJ1ozuMB4GU="; # Gunakan ini saat pertama kali, nanti ganti dengan hash aktual
  };

  # Hapus baris ini saat Anda mendapatkan hash asli

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    rofi
    libxcb
    cairo
    pango
    glib
  ];

  meta = with lib; {
    description = "Rofi script that allows creating interactive block-based interfaces";
    homepage = "https://github.com/OmarCastro/rofi-blocks";
    license = licenses.mit; # Sesuaikan dengan lisensi aktual di repository
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Tambahkan maintainer jika Anda mau
  };
}

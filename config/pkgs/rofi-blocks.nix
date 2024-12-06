{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
}:

stdenv.mkDerivation rec {
  pname = "rofi-blocks";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "OmarCastro";
    repo = "rofi-blocks";
    rev = "v${version}";
    hash = "sha256-jO1NeycBo/nl0DVfgXo5P4xU3cwZCX8KMJ1ozuMB4GU=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = {
    description = "A Rofi modi that allows controlling rofi content throug communication with an external program";
    homepage = "https://github.com/OmarCastro/rofi-blocks";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "rofi-blocks";
    platforms = lib.platforms.all;
  };
}

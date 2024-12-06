{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "elforkane";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "zakariakov";
    repo = "elforkane";
    rev = version;
    hash = "sha256-MJdmkAvDtT5B+xH4tNwuiH5IobLtgDDL8qXSsVyyeiQ=";
  };

  meta = {
    description = "The electronic Holly Quran browser Elforkane";
    homepage = "https://github.com/zakariakov/elforkane";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "elforkane";
    platforms = lib.platforms.all;
  };
}

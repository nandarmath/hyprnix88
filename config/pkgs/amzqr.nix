{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "amzqr";
  version = "0.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wklo8hpiBLX2U+B40maqhbmxF5vcBL9slAolbqW67go=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    imageio
    numpy
    pillow
  ];

  pythonImportsCheck = [
    "amzqr"
  ];

  meta = {
    description = "Generater for amazing QR Codes. Including Common, Artistic and Animated QR Codes";
    homepage = "https://pypi.org/project/amzqr/#artistic-qr-code";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "amzqr";
  };
}

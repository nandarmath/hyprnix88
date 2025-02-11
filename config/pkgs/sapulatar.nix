{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "sapulatar-qt";
  version = "1.0.dev3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-d4lVKhYGQAiLZ9Asvvh/a4glNQIJL3rF/zOMyDggj1k=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "sapulatar_qt"
  ];

  meta = {
    description = "Simple tool to help you remove background from your images/photos";
    homepage = "https://pypi.org/project/sapulatar-qt/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sapulatar-qt";
  };
}

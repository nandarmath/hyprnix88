{
  lib,
  fetchFromGitLab,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pena`";
  version = "0.1.1";

  src = fetchFromGitLab {
    owner = "nesstero";
    repo = "pena";
    tag = finalAttrs.version;
    hash = "sha256-gyWnahj1A+iXUQlQ1O1H1u7K5euYQOld9qWm99Vjaeg=";
  };

  cargoHash = "sha256-9atn5qyBDy4P6iUoHFhg+TV6Ur71fiah4oTJbBMeEy4=";

  meta = {
    description = "Pena is cms writing fot Hugo";
    homepage = "https://gitlab.com/nesstero/pena.git";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
})


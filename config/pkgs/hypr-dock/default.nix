
{ 
fetchFromGitHub
, buildGoModule
, pkg-config
, glib
, gtk3
, gtk-layer-shell
,
}:

buildGoModule rec {
  pname = "hypr-dock";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "lotos-linux";
    repo = "hypr-dock";
    rev = "v${version}";
    hash = "sha256-fMBJaupB5fDlpv+w92/cqP5OLS0UVWCUvG9QOG9vioI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    glib
    gtk3  # This includes gio, glib, and gobject
    gtk-layer-shell
  ];
  vendorHash = "sha256-KoDPQHfmYzZ/7wQAq4TKq3bIlnDLoMgH9oc4noNlSb0=";

}

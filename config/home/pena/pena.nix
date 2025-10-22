{ lib
, rustPlatform
, fetchFromGitLab
, pkg-config
, openssl
, webkitgtk
, gtk3
, libsoup
, glib-networking
, wrapGAppsHook
, makeWrapper
, cargo-tauri
, nodejs
, pnpm
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "pena";
  version = "unstable-2025-01-20";

  src = fetchFromGitLab {
    owner = "nesstero";
    repo = "pena";
    rev = "main";  # atau gunakan tag/commit hash spesifik
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  sourceRoot = "${src.name}/src-tauri";

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # Tauri memerlukan frontend yang sudah di-build
  preBuild = ''
    # Kembali ke root project untuk build frontend
    cd ..
    
    # Setup pnpm dan install dependencies
    export PNPM_HOME="$TMPDIR/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    pnpm install --frozen-lockfile
    pnpm build
    
    # Kembali ke src-tauri untuk Rust build
    cd src-tauri
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
    makeWrapper
    cargo-tauri
    nodejs
    pnpm
  ];

  buildInputs = [
    openssl
    webkitgtk
    gtk3
    libsoup
    glib-networking
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
    darwin.apple_sdk.frameworks.WebKit
    darwin.apple_sdk.frameworks.AppKit
  ];

  # Tauri build configuration
  buildPhase = ''
    runHook preBuild
    cargo tauri build --bundles deb
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    
    # Install binary dari target release
    cp target/release/pena $out/bin/
    
    # Install desktop file dan icon jika ada
    if [ -d "target/release/bundle/deb" ]; then
      # Extract dari deb bundle jika perlu
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons
      
      # Sesuaikan path jika ada .desktop file
      # cp path/to/pena.desktop $out/share/applications/
      # cp -r path/to/icons/* $out/share/icons/
    fi
    
    runHook postInstall
  '';

  # Wrap dengan GApps untuk GTK themes
  postFixup = ''
    wrapProgram $out/bin/pena \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ webkitgtk gtk3 ]}" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
  '';

  meta = with lib; {
    description = "Pena - Aplikasi Tauri dari Nesstero";
    homepage = "https://gitlab.com/nesstero/pena";
    license = licenses.mit;  # Sesuaikan dengan lisensi actual
    maintainers = [ ];
    mainProgram = "pena";
    platforms = platforms.linux ++ platforms.darwin;
  };
}

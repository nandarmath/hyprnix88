# Tambahkan ini ke configuration.nix Anda

{pkgs, ... }:

let
  hyprlandMonitorManager = pkgs.writeShellScriptBin "hyprland-monitor-manager" ''
    #!${pkgs.python3}/bin/python3
    
    ${builtins.readFile ./hyprland_monitor_manager.py}
  '';
  
  # Atau jika Anda ingin menggunakan buildPythonApplication
  hyprlandMonitorManagerApp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "hyprland-monitor-manager";
    version = "1.0.0";
    format = "other";
    
    src = pkgs.writeTextFile {
      name = "hyprland_monitor_manager.py";
      text = builtins.readFile ./hyprland_monitor_manager.py;
    };
    
    propagatedBuildInputs = with pkgs.python3Packages; [
      tkinter
    ];
    
    buildInputs = with pkgs; [
      hyprland
      bash
      coreutils
      systemd
      procps
    ];
    
    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];
    
    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin
      cp $src $out/bin/hyprland-monitor-manager
      chmod +x $out/bin/hyprland-monitor-manager
      
      # Wrap dengan dependencies yang diperlukan
      wrapProgram $out/bin/hyprland-monitor-manager \
        --prefix PATH : ${pkgs.lib.makeBinPath [
          pkgs.hyprland
          pkgs.bash
          pkgs.coreutils
          pkgs.systemd
          pkgs.procps
          pkgs.python3
        ]}
      
      runHook postInstall
    '';
    
    meta = with pkgs.lib; {
      description = "GUI Monitor Manager for Hyprland";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

in
{
  # Opsi 1: Menggunakan writeShellScriptBin (lebih sederhana)
  environment.systemPackages = with pkgs; [
    hyprlandMonitorManagerApp
    # Dependencies yang diperlukan
    hyprland
    python3
    python3Packages.tkinter
    systemd
    procps
  ];
  
  # Opsi 2: Menggunakan buildPythonApplication (lebih proper)
  # environment.systemPackages = with pkgs; [
  #   hyprlandMonitorManagerApp
  # ];

  # Pastikan layanan yang diperlukan aktif
  
  # Atau jika menggunakan home-manager, tambahkan ke home.nix:
  # home.packages = with pkgs; [
  #   hyprlandMonitorManager
  # ];
}

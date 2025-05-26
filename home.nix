{ config, pkgs, inputs, username,
  gtkThemeFromScheme, ... }:
let 
  inherit (import ./options.nix)
    gitUsername gitEmail theme ;
in {
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  # Set The Colorscheme
  # colorScheme = inputs.nix-colors.colorSchemes."${theme}";

  # Import Program Configurations
  imports = [
    # inputs.nix-colors.homeManagerModules.default
    # inputs.hyprland.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    inputs.nxchad.homeManagerModules.nixvim
    # inputs.anyrun.homeManagerModules.default
    # inputs.walker.homeManagerModules.default
    ./config/home
  ];

  # Define Settings For Xresources
  xresources.properties = {
    "Xcursor.size" = 24;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    extraConfig = {
      init.defaultBranch = "main";
      safe.directory = "/home/nandar/Data/01 My Data/01 Kuliah/18_Persiapan Tesis";
      };
  };
  
  # config ssh
  programs.ssh = {
    enable = true;
    extraConfig = ''
      #Account 1
      Host github.com-akun1
        HostName github.com
        User git
        Identityfile ~/.ssh/id_ed2519_akun1
        IdentitiesOnly yes

      #Account 2
      Host github.com-akun2
        HostName github.com
        User git
        Identityfile ~/.ssh/id_ed2519_akun2
        IdentitiesOnly yes

      #Account 3
      Host gitlab.com
        HostName gitlab.com
        User git
        Identityfile ~/.ssh/id_ed2519_akun1
        IdentitiesOnly yes

    '';
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
        enable = true;
        createDirectories = true;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs.home-manager.enable = true;
}

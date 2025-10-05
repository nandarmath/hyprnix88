{
  description = "HypernixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-colors.url = "github:misterio77/nix-colors";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix = {
      url = "github:danth/stylix/release-25.05";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # zen zen-browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    # neovim in nix
    nvf.url = "github:notashelf/nvf";
    # repo xdman
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    fmpkgs.url = "github:fmway/fmpkgs";
    ags.url = "github:Aylur/ags";
    sops-nix.url = "github:Mic92/sops-nix";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    # nxchad.url = "github:nandarmath/nxchad";
    nxchad.url = "git:/home/nandar/Documents/NxChad";
    # This is important, since nxchad dosn't add nixpkgs repo in dependencies
    nxchad.inputs.nixpkgs.follows = "nixpkgs";
    # nvchad4nix = {
    # url = "github:MOIS3Y/nvchad4nix";
    # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # anyrun = {
    #   url = "github:anyrun-org/anyrun";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    nixpkgs-r2405.url = "github:NixOs/nixpkgs/nixos-24.05";
    nixpkgs-r2205.url = "github:NixOs/nixpkgs/nixos-22.05";
    nixpkgs-rnew.url = "github:NixOs/nixpkgs/nixos-unstable";
    # walker.url = "github:abenz1267/walker";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      stylix,
      nix-flatpak,
      home-manager,
      sops-nix,
      nixpkgs-r2405,
      nixpkgs-r2205,
      nixpkgs-rnew,
      fmpkgs,
      chaotic,
      # anyrun,
      nixos-hardware,
      ...
    }:
    let
      system = "x86_64-linux";
      overlay-r2405 = final: prev: {
        r2405 = import nixpkgs-r2405 {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlay-r2205 = final: prev: {
        r2205 = import nixpkgs-r2205 {
          inherit system;
          config.allowUnfree = true;
        };
      };
      overlay-rnew = final: prev: {
        rnew = import nixpkgs-rnew {
          inherit system;
          config.allowUnfree = true;
        };
      };
      inherit (import ./options.nix) username hostname;

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit inputs;
            inherit username;
            inherit hostname;
          };

          modules = [
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.overlays = [
                  overlay-r2405
                  overlay-r2205
                  overlay-rnew
                ];
              }
            )
            # {nixpkgs.overlays = [inputs.fmpkgs.overlays.default];}
            # {inherit (inputs.fmpkgs) nixpkgs;}
            # {environment.systemPackages = [
            # anyrun.packages.${system}.anyrun-with-all-plugins
            # ];}
            ./system.nix
            chaotic.nixosModules.default
            # stylix.nixosModules.stylix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
            nixos-hardware.nixosModules.lenovo-thinkpad-x390
            {
              home-manager.extraSpecialArgs = {
                inherit username;
                inherit inputs;
                # inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
              };
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${username} = import ./home.nix;
                # home-manager.users.${username}.initialPassword = "1988";
              };
            }
            # nixvim.nixosModules.nixvim
            # nxchad.nixosModules.nixvim
          ];
        };
      };
    };
}

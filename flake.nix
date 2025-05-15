{
  description = "HypernixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-colors.url = "github:misterio77/nix-colors";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix.url = "github:danth/stylix/release-24.11";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # zen zen-browser
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    # neovim in nix
    nvf.url = "github:notashelf/nvf";
    # repo xdman
    fmpkgs.url = "github:fmway/fmpkgs";
    impermanence.url = "github:nix-community/impermanence";
    ags.url = "github:Aylur/ags";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nxchad.url = "github:fmway/nxchad";
    # This is important, since nxchad dosn't add nixpkgs repo in dependencies
    nxchad.inputs.nixpkgs.follows = "nixpkgs";



    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-r2405.url = "github:NixOs/nixpkgs/nixos-24.05";
    nixpkgs-r2205.url = "github:NixOs/nixpkgs/nixos-22.05";
    nixpkgs-new.url = "github:nixos/nixpkgs/nixos-unstable";
    walker.url = "github:abenz1267/walker";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    stylix,
    home-manager,
    impermanence,
    sops-nix,
    nixpkgs-r2405,
    nixpkgs-r2205,
    nixpkgs-new,
    fmpkgs,
    chaotic,
    nixvim,
    nxchad,
    ...
  }: let
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
    overlay-new = final: prev: {
      new = import nixpkgs-new {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
    };
    inherit (import ./options.nix) username hostname;

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.hyprpanel.overlay
      ];
    };
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit system;
          inherit inputs;
          inherit username;
          inherit hostname;
        };

        modules = [
          ({
            config,
            pkgs,
            ...
          }: {nixpkgs.overlays = [overlay-r2405 overlay-r2205 overlay-new inputs.hyprpanel.overlay];})
          {nixpkgs.overlays = [inputs.fmpkgs.overlays.default];}
          {inherit (inputs.fmpkgs) nixpkgs;}
          # {environment.systemPackages = [ anyrun.packages.${system}.anyrun ];}
          ./system.nix
          chaotic.nixosModules.default
          # stylix.nixosModules.stylix
          sops-nix.nixosModules.sops
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          nixvim.nixosModules.nixvim
          nxchad.nixosModules.nixvim
          {
            home-manager.extraSpecialArgs = {
              inherit username;
              inherit inputs;
              # inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
              inherit overlay-new;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home.nix;
            # home-manager.users.${username}.initialPassword = "1988";
          }
        ];
      };
    };
  };
}

{
  description = "HypernixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-colors.url = "github:misterio77/nix-colors";
    #hyprland.url = "github:hyprwm/Hyprland";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
      };
    hyprgrass = {
         url = "github:horriblename/hyprgrass";
         inputs.hyprland.follows = "hyprland"; # IMPORTANT
      };
    flake-parts.url = "github:hercules-ci/flake-parts";
    #### ---- nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      };
    nvix = {
      url = "github:niksingh710/nvix";
      inputs.nixpkgs.follows = "nixpkgs";
      }; 
     anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     fmpkgs.url = "github:fmway/fmpkgs";

    impermanence.url = "github:nix-community/impermanence";
    joshuto.url = "github:kamiyaa/joshuto";
    ags.url ="github:Aylur/ags";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-r2405.url = "github:NixOs/nixpkgs/nixos-24.05";
    # nixpkgs-r2411.url = "github:NixOs/nixpkgs/nixos-24.11";
    walker.url = "github:abenz1267/walker";

  };

  outputs = inputs@{ self, nixpkgs, home-manager, impermanence, joshuto, hyprpanel, sops-nix,nixvim, nixpkgs-r2405, anyrun, fmpkgs, ... }:
  let
    system = "x86_64-linux";
    overlay-r2405 = final: prev:{
      r2405=import nixpkgs-r2405 {
        inherit system;
        config.allowUnfree= true;
      };
    };
    inherit (import ./options.nix) username hostname;

    pkgs = import nixpkgs {
      inherit system;
      config = {
	    allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
	specialArgs = { 
          inherit system; inherit inputs; 
          inherit username; inherit hostname;
        };
	modules = [ 
    ({config, pkgs, ...}:{nixpkgs.overlays = [overlay-r2405 inputs.hyprpanel.overlay];})
    { nixpkgs.overlays = [inputs.fmpkgs.overlays.default]; }
    { inherit (inputs.fmpkgs) nixpkgs; }
	  {environment.systemPackages = [ anyrun.packages.${system}.anyrun ];}
  ./system.nix
    sops-nix.nixosModules.sops
    nixvim.nixosModules.nixvim
	  impermanence.nixosModules.impermanence
    home-manager.nixosModules.home-manager {
	    home-manager.extraSpecialArgs = {
	      inherit username; inherit inputs;
              inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
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

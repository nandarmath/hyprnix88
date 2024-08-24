{
  description = "ZaneyOS";

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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    joshuto.url = "github:kamiyaa/joshuto";
    ags.url ="github:Aylur/ags";
    sops-nix.url = "github:Mic92/sops-nix";

    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, home-manager, impermanence, joshuto, sops-nix, ... }:
  let
    system = "x86_64-linux";
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
	  ./system.nix
    sops-nix.nixosModules.sops
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

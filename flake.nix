{
  description = "Kevin's Nixos Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Does not follow input.nixpkgs to prevent unexpected bugs
    nixvim = {
      url = "github:nix-community/nixvim?rev=695b0b80f8452bc584adf23eb58bdc9f599e35eb";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    nixvim,
    stylix,
    sops-nix,
    treefmt-nix,
    git-hooks-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    forEachSystem = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-darwin"];

    # Helper Function to Create NixOS Configs
    mkNixosConfig = hostname: profile: username:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs hostname profile username;
          osFamily = "linux";
        };
        modules = [
          ./hosts/${profile}
          sops-nix.nixosModules.sops

          stylix.nixosModules.stylix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs hostname profile username;
                osFamily = "linux";
              };
              sharedModules = [nixvim.homeModules.nixvim];
              users.${username} = import ./home/hosts/${profile}.nix;
            };
          }
        ];
      };

    # Helper Function to Create Darwin Configs
    mkDarwinConfig = hostname: profile: username: let
      darwinSystem = "aarch64-darwin";
    in
      nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          inherit inputs hostname profile username;
          osFamily = "darwin";
        };
        modules = [
          ./hosts/${profile}
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit inputs hostname profile username;
                osFamily = "darwin";
              };
              sharedModules = [nixvim.homeModules.nixvim];
              users.${username} = import ./home/hosts/${profile}.nix;
            };
          }
        ];
      };
  in {
    nixosConfigurations = {
      beans-btw = mkNixosConfig "beans-btw" "chromebook" "kevin";
      uribo-btw = mkNixosConfig "uribo-btw" "server" "uribo";
    };

    darwinConfigurations = {
      kebee = mkDarwinConfig "kebee" "macbook" "beellm";
    };

    formatter = forEachSystem (
      sys:
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${sys} ./treefmt.nix).config.build.wrapper
    );

    checks.${system}.pre-commit-check = git-hooks-nix.lib.${system}.run {
      src = ./.;
      inherit (import ./git-hooks.nix {inherit pkgs;}) hooks;
    };
  };
}

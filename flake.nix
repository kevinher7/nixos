{
  description = "Kevin's Nixos Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
  };

  outputs = { nixpkgs, home-manager, nixvim, stylix, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      # Helper Function to Create Configs
      mkNixosConfig = hostname: profile: username:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname profile username; };
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
                extraSpecialArgs = { inherit inputs hostname profile username; };
                sharedModules = [ nixvim.homeModules.nixvim ];
                users.${username} = import ./home/hosts/${profile}.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        beans-btw = mkNixosConfig "beans-btw" "chromebook" "kevin";
        uribo-btw = mkNixosConfig "uribo-btw" "server" "uribo";
      };
    };
}

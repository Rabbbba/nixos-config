{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mango }: {
    nixosConfigurations.Rayane = nixpkgs.lib.nixosSystem {
      specialArgs = { inputs = { inherit home-manager mango; }; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        mango.nixosModules.mango
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inputs = { inherit home-manager mango; }; };
          home-manager.users.rayane = import ./home.nix;
        }
      ];
    };
  };
}

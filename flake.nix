{
  description = "Configuration NixOS de Rayane";

  inputs = {
    # nixpkgs unstable — packages cutting-edge
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # home-manager — gestion des dotfiles utilisateur en module NixOS
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mango — window manager Wayland (fork de dwl)
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, mango }: {
    # Configuration système — l'hostname doit matcher (Rayane)
    nixosConfigurations.Rayane = nixpkgs.lib.nixosSystem {
      # `inputs` passé aux modules pour qu'ils puissent y accéder
      specialArgs = { inputs = { inherit home-manager mango; }; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        mango.nixosModules.mango
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # `inputs` passé aussi aux modules home-manager (pour mango.hmModules)
          home-manager.extraSpecialArgs = { inputs = { inherit home-manager mango; }; };
          home-manager.users.rayane = import ./home.nix;
        }
      ];
    };
  };
}

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

    # Quickshell — bleeding-edge depuis l'upstream officiel
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Kernel CachyOS via xddxdd — BORE scheduler pour transferts CPU↔GPU intensifs
    # NOTE : ne pas override son input nixpkgs (mismatch patches/kernel version).
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, home-manager, quickshell, nix-cachyos-kernel }: {
    nixosConfigurations.Rayane = nixpkgs.lib.nixosSystem {
      specialArgs = { inputs = { inherit home-manager quickshell; }; };

      modules = [
        ./configuration.nix
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inputs = { inherit home-manager quickshell; }; };
          home-manager.users.rayane = import ./home.nix;
        }
      ];
    };
  };
}

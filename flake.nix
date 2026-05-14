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

    # Zen Browser — Firefox fork avec UI moderne (split tabs, workspaces, sidebar)
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # qml-language-server — LSP QML Go/tree-sitter (alternative à qmlls Qt)
    qml-language-server = {
      url = "github:cushycush/qml-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      quickshell,
      nix-cachyos-kernel,
      zen-browser,
      qml-language-server,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.Rayane = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inputs = {
            inherit
              home-manager
              quickshell
              zen-browser
              qml-language-server
              ;
          };
        };

        modules = [
          ./configuration.nix
          { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inputs = {
                inherit
                  home-manager
                  quickshell
                  zen-browser
                  qml-language-server
                  ;
              };
            };
            home-manager.users.rayane = import ./home.nix;
          }
        ];
      };

      # Devshell : `nix develop` (ou auto-load via `direnv` + `.envrc`).
      # Source de vérité pour les outils utilisés en local ET dans le CI
      # (cf. .github/workflows/lint.yml qui utilise `nix develop --command`).
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Documentation
          doxygen
          graphviz
          uv # pour `uvx doxyqml` (cf. quickshell/doxyqml-wrapper.sh)

          # Linters Nix
          statix # détecteur d'anti-patterns
          deadnix # détecteur de code mort
          nixfmt-rfc-style # formateur Nix (style RFC 166)

          # Linters QML / shell / lua
          qt6.qtdeclarative # fournit qmllint, qmlformat
          shellcheck
          stylua # formateur Lua (config dans stylua.toml)

          # Plugin Quickshell C++ — headers Qt6 + wrapper Nix
          # (gcc/cmake/pkg-config viennent du home.nix global)
          qt6.qtbase # QObject, QTimer, Qt Core/Gui
          qt6.qtdeclarative # Qt6::Qml — nécessaire pour QML_ELEMENT macro
          qt6.qtshadertools # Dépendance transitive de Qt6Quick
          qt6.wrapQtAppsHook # patche les rpath Qt automatiquement pour la dérivation
          libGL # WrapOpenGL — dépendance transitive de Qt6Gui sur NixOS
        ];

        shellHook = ''
          # Qt6 sur NixOS éclate ses composants en plusieurs paquets (qtbase,
          # qtdeclarative, qtshadertools…). `find_package(Qt6 COMPONENTS …)`
          # de CMake n'agrège pas tout seul ; on lui donne explicitement les
          # racines via CMAKE_PREFIX_PATH pour qu'il résolve les Config.cmake
          # de chaque composant.
          export CMAKE_PREFIX_PATH="${pkgs.qt6.qtbase}:${pkgs.qt6.qtdeclarative}:${pkgs.qt6.qtshadertools}''${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"

          echo ""
          echo "  nixos-config devshell ready."
          echo ""
          echo "  Common commands:"
          echo "    cd quickshell && doxygen Doxyfile     build docs locally"
          echo "    statix check .                        nix anti-pattern lint"
          echo "    deadnix .                             find unused nix code"
          echo "    nixfmt --check **/*.nix               check nix formatting"
          echo "    qmllint quickshell/**/*.qml           qml lint"
          echo "    shellcheck hypr/scripts/*.sh          shell lint"
          echo "    stylua --check nvim/                  lua format check"
          echo ""
          echo "  C++ / Qt6 plugin :"
          echo "    cmake -B build -S .                   configure"
          echo "    cmake --build build                   compile"
          echo ""
        '';
      };
    };
}

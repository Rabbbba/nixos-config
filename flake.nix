{
  description = "Rayane's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # do NOT override nixpkgs here — patch/version mismatch
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    qml-language-server = {
      url = "github:cushycush/qml-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    odysseus = {
      url = "github:ToyVo/odysseus/feat-add-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      quickshell,
      nix-cachyos-kernel,
      qml-language-server,
      pre-commit-hooks,
      odysseus,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Native C++ QML plugin (NativeSensors) built from quickshell/plugin/.
      # Installs to $out/lib/qt-6/qml/NativeSensors, fed to QML_IMPORT_PATH in home.nix.
      # Pre-commit hooks — auto-installed by devShell shellHook.
      # Also runnable standalone: nix flake check
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          statix.enable = true;
          deadnix = {
            enable = true;
            excludes = [ "hardware-configuration\.nix" ];
          };
          nixfmt.enable = true;
          shellcheck.enable = true;
          stylua.enable = true;

          # Custom: Doxygen on staged QML (mirrors CI docs.yml)
          doxygen-qml = {
            enable = true;
            name = "doxygen-qml";
            description = "Run Doxygen when QML files are staged";
            entry = "${pkgs.writeShellScript "doxygen-qml-hook" ''
              set -e
              cd quickshell && doxygen Doxyfile
            ''}";
            files = "quickshell/.*\\.qml$";
            pass_filenames = false;
            language = "system";
          };
        };
        tools = {
          inherit (pkgs) doxygen graphviz;
        };
      };

      nativeSensors = pkgs.stdenv.mkDerivation {
        pname = "quickshell-native-sensors";
        version = "1.0";

        # Whole plugin dir; git already excludes build/, .cache/, compile_commands.json.
        src = pkgs.lib.fileset.toSource {
          root = ./quickshell/plugin;
          fileset = ./quickshell/plugin;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          qt6.wrapQtAppsHook # Qt6 CMake integration so find_package(Qt6) resolves
          autoPatchelfHook # rewrite the plugin RPATH to find Qt + the backing lib
        ];

        buildInputs = with pkgs; [
          qt6.qtbase
          qt6.qtdeclarative
        ];

        # CMake bakes the build-tree dir into the RPATH by default; Nix forbids
        # that /build reference. Skip it — autoPatchelfHook sets the real RPATH.
        cmakeFlags = [ "-DCMAKE_SKIP_BUILD_RPATH=ON" ];

        # qt_add_qml_module emits no install() rules, so install by hand. The
        # plugin .so links the backing lib, so both sit in the module dir
        # ($ORIGIN) and autoPatchelfHook fixes the RPATH.
        installPhase = ''
          runHook preInstall
          dir=$out/lib/qt-6/qml/NativeSensors
          mkdir -p $dir
          cp -r NativeSensors/* $dir/
          cp libquickshell-native-sensors.so $dir/
          runHook postInstall
        '';
      };
    in
    {
      packages.${system}.native-sensors = nativeSensors;

      checks.${system} = {
        inherit pre-commit-check;
      };

      nixosConfigurations.Rayane = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inputs = {
            inherit
              home-manager
              quickshell
              qml-language-server
              ;
          };
        };

        modules = [
          ./configuration.nix
          { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
          odysseus.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit nativeSensors;
              inputs = {
                inherit
                  home-manager
                  quickshell
                  qml-language-server
                  ;
              };
            };
            home-manager.users.rayane = import ./home.nix;
          }
        ];
      };

      # `nix develop` (or auto via direnv). Shared with CI — see workflows/lint.yml.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          doxygen
          graphviz
          uv # for uvx doxyqml — see quickshell/doxyqml-wrapper.sh

          statix
          deadnix
          nixfmt

          qt6.qtdeclarative # qmllint, qmlformat
          shellcheck
          stylua

          # Quickshell C++ plugin (gcc/cmake/pkg-config live in home.nix)
          qt6.qtbase
          qt6.qtdeclarative # Qt6::Qml — required for QML_ELEMENT
          qt6.qtshadertools
          qt6.wrapQtAppsHook
          libGL
        ];

        shellHook = pre-commit-check.shellHook + ''
          # Qt6 is split across packages on NixOS; CMake's find_package doesn't
          # aggregate them, so feed it each component root via CMAKE_PREFIX_PATH.
          export CMAKE_PREFIX_PATH="${pkgs.qt6.qtbase}:${pkgs.qt6.qtdeclarative}:${pkgs.qt6.qtshadertools}''${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"

          echo ""
          echo "  nixos-config devshell ready."
          echo ""
          echo "  Pre-commit hooks: auto-installed (statix, deadnix, nixfmt, shellcheck, stylua, doxygen-qml)"
          echo "    pre-commit run --all-files            run all hooks on the whole repo"
          echo "    pre-commit run <hook-id>              run a single hook"
          echo ""
          echo "  C++ / Qt6 plugin :"
          echo "    cmake -B build -S .                   configure"
          echo "    cmake --build build                   compile"
          echo ""
        '';
      };
    };
}

{
  config,
  pkgs,
  inputs,
  nativeSensors,
  ...
}:

let
  # Quickshell needs the native NativeSensors plugin on its QML import path.
  # Its store path is dynamic, so it must be interpolated here (never hardcoded
  # in a static config). Shared by sessionVariables (dev / manual runs) and the
  # quickshell systemd service (the autostarted bar, which doesn't inherit the
  # login shell's environment).
  qmlImportPath = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  }/lib/qt-6/qml:${nativeSensors}/lib/qt-6/qml";
in
{
  # ── Identity ────────────────────────────────────────────────────────────────
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ── dotfiles ── symlinks so edits stay live without a rebuild
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/quickshell";
  xdg.configFile."foot".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/foot";
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/hypr";
  xdg.configFile."walker".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/walker";
  xdg.configFile."dunst".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dunst";
  xdg.configFile."cava".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/cava";
  xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/matugen";
  xdg.configFile."starship.toml".source = ./starship.toml;

  home.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";

  home.sessionPath = [ "$HOME/.local/bin" ];

  # ── Packages ────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Media
    playerctl
    pavucontrol
    easyeffects
    tidal-hifi
    sox
    matugen

    # Terminal & shell
    foot

    # Editor & dev tools
    neovim
    nixd
    nixfmt
    statix
    deadnix
    # ─── C/C++ toolchain ─────────────────────────────────────────────
    # clang-tools already gives us the LSP side; this row is for compiling.
    gcc
    cmake
    ninja
    pkg-config
    gdb
    bear # compile_commands.json from any build → clangd
    cppcheck
    valgrind
    clang-tools
    # ─── C/C++ learning ──────────────────────────────────────────────
    zeal # offline cppreference/Qt/STL, sqlite-indexed
    cling # C++ REPL
    exercism
    cppman # cppreference as man pages
    bash-language-server
    vscode-langservers-extracted
    stylua
    prettier
    qt6.qtdeclarative # qmlformat
    inputs.qml-language-server.packages.${pkgs.stdenv.hostPlatform.system}.default
    taplo
    shfmt
    nodejs
    ripgrep
    gh
    doxygen
    graphviz # DOT for Doxygen inheritance diagrams

    # WM & desktop (hyprland itself is system-wide via programs.hyprland)
    hyprlock
    hypridle
    awww # wallpaper daemon, replaces hyprpaper
    matugen
    cava
    walker
    elephant # walker 2.x data backend
    dunst
    libnotify
    swayosd

    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Capture & clipboard
    grim
    slurp
    wl-clipboard
    wl-clip-persist # survives the source app closing
    cliphist

    # Apps
    # Vesktop: never launch via walker — its app.slice cgroup + detached fork
    # breaks Chromium's video_capture (portal picker never opens, black frame).
    # Use Super+D (direct exec, clean systemd scope).
    pkgs.vesktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    bitwarden-desktop
    mangohud
    obsidian
    superfile

    # Gaming
    protonup-qt
    protontricks
    heroic
    goverlay
    gamescope

    # AI
    claude-code
    pi-coding-agent
    bubblewrap # required by pi-sandbox

    amdgpu_top
    networkmanagerapplet
    btop
    bc
    unzip
    unrar # rar backend used by file-roller via PATH
    file-roller # GUI archive frontend, integrates with thunar-archive-plugin
    jq # used by hypr scripts
    socat # listens to hyprland events
    hyprpolkitagent # privilege prompts for LACT, gparted...

    # `, <bin>` runs any nixpkgs binary ephemerally (needs nix-index, below)
    comma
    hydralauncher

    # Fonts
    nerd-fonts.iosevka
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Amber";
    XCURSOR_SIZE = "24";
    QML_IMPORT_PATH = qmlImportPath;

    # 1 GiB default evicts mid-session on modern AAA → hot recompiles (UE5).
    MESA_SHADER_CACHE_MAX_SIZE = "10G";
    # one index file beats millions of small ones on btrfs
    MESA_DISK_CACHE_SINGLE_FILE = "1";
  };

  #Qt
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  #Mouse
  home.pointerCursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark-B";
      package = pkgs.gruvbox-gtk-theme;
    };
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # ── Programs ────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings.user.name = "Rayane";
    settings.user.email = "rayane.bensalah@proton.me";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship.enable = true;

  # smart cd — `z <fragment>` jumps by frecency
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # fuzzy file/dir picker — Ctrl-T (files), Alt-C (dirs), pairs with zoxide
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # backs `comma` and `command-not-found` with a nixpkgs binary index
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # TUI git — visual branches/stage/conflicts; complements neovim
  programs.lazygit.enable = true;

  # shell history backed by SQLite — Ctrl-R opens a fuzzy TUI with cwd/exit/duration
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      inline_height = 20; # panel above prompt instead of fullscreen
      style = "compact";
      show_preview = true;
    };
  };

  # ── Systemd user services ──────────────────────────────────────────────────
  # walker + elephant + quickshell bound to graphical-session.target, which
  # UWSM starts automatically when Hyprland enters its systemd scope.
  systemd.user.services.elephant = {
    Unit = {
      Description = "Elephant — data provider for walker";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.walker = {
    Unit = {
      Description = "Walker — application launcher";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "elephant.service"
      ];
      Requires = [ "elephant.service" ];
    };
    Service = {
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # The bar runs as a service (not a Hyprland exec-once) so it gets a controlled
  # environment: Hyprland's env lacks QML_IMPORT_PATH, so an exec-once couldn't
  # find the NativeSensors plugin and the bar failed to start at boot.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell — custom Wayland bar / shell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = "QML_IMPORT_PATH=${qmlImportPath}";
      # Wait for NetworkManager on the system bus — Quickshell's network
      # backend only probes once at startup and silently disables itself
      # if the D-Bus name isn't owned yet, leaving the Wi-Fi popup empty.
      ExecStartPre = "${pkgs.writeShellScript "wait-nm" ''
        for i in $(seq 1 50); do
          ${pkgs.systemd}/bin/busctl --system status org.freedesktop.NetworkManager >/dev/null 2>&1 && exit 0
          sleep 0.2
        done
      ''}";
      ExecStart = "${
        inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/bin/quickshell -p /etc/nixos/quickshell/shell.qml";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ── Daemons migrated from Hyprland exec-once ───────────────────────────────
  # All bound to graphical-session.target so UWSM starts/stops them with the
  # session and systemd restarts them on failure.

  systemd.user.services.foot-server = {
    Unit = {
      Description = "foot — shared terminal server (one process for all clients)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.foot}/bin/foot --server";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "awww — Wayland wallpaper daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Sets the initial wallpaper once awww-daemon is up. wallpaper.sh also
  # regenerates the Quickshell matugen theme from the OLED image. Tied to
  # awww-daemon (not graphical-session.target) to avoid an ordering cycle:
  # awww-daemon already runs after graphical-session, so re-linking
  # wallpaper to that target would close the loop.
  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Apply per-output wallpapers and regenerate theme";
      Requires = [ "awww-daemon.service" ];
      After = [ "awww-daemon.service" ];
    };
    Service = {
      Type = "oneshot";
      # awww-daemon doesn't expose a readiness signal, so poll the socket.
      ExecStartPre = "${pkgs.writeShellScript "wait-awww" ''
        for i in $(seq 1 50); do
          ${pkgs.awww}/bin/awww query >/dev/null 2>&1 && exit 0
          sleep 0.1
        done
      ''}";
      ExecStart = "/etc/nixos/hypr/scripts/wallpaper.sh";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "awww-daemon.service" ];
  };

  systemd.user.services.hypridle = {
    Unit = {
      Description = "hypridle — idle management daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.dunst = {
    Unit = {
      Description = "dunst — notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.dunst}/bin/dunst";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.swayosd-server = {
    Unit = {
      Description = "swayosd — on-screen volume/brightness display server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager applet (tray)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "wl-clip-persist — keep clipboard contents after source app closes";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular --reconnect-tries 0";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # wl-paste --watch invokes cliphist on every clipboard change — no shell pipe.
  systemd.user.services.cliphist-store = {
    Unit = {
      Description = "cliphist — record clipboard text history via wl-paste --watch";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.easyeffects = {
    Unit = {
      Description = "easyeffects — PipeWire audio effects (background service)";
      PartOf = [ "graphical-session.target" ];
      # Needs PipeWire and WirePlumber up — the gapplication-service exits
      # immediately ("QLocalSocket: device not open") if they aren't ready.
      Requires = [
        "pipewire.service"
        "wireplumber.service"
      ];
      After = [
        "graphical-session.target"
        "pipewire.service"
        "wireplumber.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Redefines the unit shipped by pkgs.hyprpolkitagent — home-manager builds
  # a fresh .service per entry, so an Install-only override would produce an
  # incomplete file. Kept in sync with share/systemd/user/hyprpolkitagent.service.
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Authentication Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Slice = "session.slice";
      TimeoutStopSec = "5sec";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}

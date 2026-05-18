{
  config,
  pkgs,
  inputs,
  ...
}:

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
    inputs.qml-language-server.packages.${pkgs.system}.default
    taplo
    shfmt
    nodejs
    ripgrep
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

    inputs.quickshell.packages.${pkgs.system}.default

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
    inputs.zen-browser.packages.${pkgs.system}.default
    bitwarden-desktop
    mangohud
    obsidian

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
    jq # used by hypr scripts
    socat # listens to hyprland events
    hyprpolkitagent # privilege prompts for LACT, gparted...

    # `, <bin>` runs any nixpkgs binary ephemerally (needs nix-index, below)
    comma

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
    QML_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${
      inputs.quickshell.packages.${pkgs.system}.default
    }/lib/qt-6/qml";

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
  # walker + elephant under systemd for restart-on-failure. hyprland-session
  # is started from autostart.conf and binds to graphical-session.target.
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

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

}

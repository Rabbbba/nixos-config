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

  # ── Dotfiles (symlinks vers /etc/nixos pour rester writables) ──────────────
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

  # Scripts perso non-versionnés
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

    # Éditeur & outils dev
    neovim
    nixd # LSP Nix
    nixfmt # Formateur Nix
    statix # Linter anti-patterns Nix
    deadnix # Détecte bindings let inutilisés
    clang-tools # LSP C/C++
    bash-language-server # LSP Bash
    vscode-langservers-extracted # LSP HTML/CSS/JSON
    stylua # Formateur Lua
    prettier # Formateur JS/MD/YAML
    qt6.qtdeclarative # Fourni qmlformat (LSP qmlls aussi mais on utilise qml-language-server à la place)
    inputs.qml-language-server.packages.${pkgs.system}.default # LSP QML Go/tree-sitter
    taplo # Formateur TOML
    shfmt # Formateur Shell
    nodejs
    ripgrep
    doxygen # Génération doc (cf quickshell/Doxyfile)
    graphviz # Diagrammes d'héritage pour Doxygen (DOT)

    # Window manager & desktop
    # hyprland — fourni par programs.hyprland system-wide (configuration.nix)
    hyprlock # Lock screen
    hypridle # Idle daemon
    awww # Wallpaper daemon (replaces hyprpaper)
    matugen # Material You palette generation from wallpaper
    cava # Audio spectrum visualizer feeding the Tidal popup bars
    walker # Lanceur d'apps
    elephant # Backend data provider pour walker 2.x
    dunst # Notifications
    libnotify # notify-send pour tester dunst
    swayosd # OSD volume/luminosité (compositor-agnostic)

    #Quickshell (Projet) — bleeding-edge depuis flake input
    inputs.quickshell.packages.${pkgs.system}.default

    # Capture & presse-papiers
    grim
    slurp
    wl-clipboard
    wl-clip-persist # Garde le clipboard après fermeture
    cliphist # Historique presse-papiers

    # Apps
    # Vesktop : Discord client avec support Wayland (remplace discord upstream).
    # ⚠️ NE PAS LANCER via walker — le launcher casse le pipeline Chromium
    # video_capture (cgroup app.slice + fork detaché → "Bind context provider
    # failed", picker portail ne s'ouvre pas, frame noire côté viewer).
    # Utiliser Super+D (bind Hyprland → exec direct, scope systemd propre).
    # Historique : on traînait des flags --disable-gpu-memory-buffer-video-frames
    # / --disable-features=AcceleratedVideoEncoder / --enable-features=
    # WebRTCPipeWireCapturer pour "fixer" la frame noire RDNA4 — en fait c'était
    # walker depuis le début, les flags étaient inutiles. Vanilla suffit.
    pkgs.vesktop
    inputs.zen-browser.packages.${pkgs.system}.default # Firefox fork avec UI moderne
    bitwarden-desktop
    mangohud
    obsidian

    # Gaming
    protonup-qt # Gestion Proton-GE
    protontricks # Tweaks/DLLs pour jeux Proton
    heroic # GOG / Epic Games / Amazon Prime
    goverlay # GUI config MangoHud
    gamescope # Compositeur dédié jeux (FSR, HDR)

    # IA
    claude-code
    pi-coding-agent
    bubblewrap # Sandbox userland — requis par pi-sandbox pour isoler skills/cmds

    amdgpu_top # Monitoring GPU AMD
    networkmanagerapplet # Tray network
    btop
    bc # Calculatrice CLI
    jq # JSON parsing — utilisé par les scripts Hyprland
    socat # Socket cat — utilisé pour écouter events Hyprland
    hyprpolkitagent # Agent polkit pour Hyprland (requis pour LACT, gparted, etc.)

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

    # Gaming — réduit les stutters de compilation shader (UE5 notamment).
    # Par défaut Mesa cap le cache à 1 GiB ; un AAA récent évince ses propres
    # entrées en cours de session, ce qui re-déclenche des compiles à chaud.
    MESA_SHADER_CACHE_MAX_SIZE = "10G";
    # Index unique au lieu de millions de petits fichiers — réduit la pression
    # inode + IO sur btrfs au démarrage des jeux avec gros cache shader.
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

  # ── Systemd user services ──────────────────────────────────────────────────
  # Walker launcher + elephant backend, managed by systemd so they survive
  # rebuilds and restart on failure. hyprland-session.target is started by
  # Hyprland (see hypr/modules/autostart.conf) — it pulls in graphical-session.target
  # via BindsTo, which our services depend on.
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

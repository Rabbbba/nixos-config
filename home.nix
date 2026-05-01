{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.mango.hmModules.mango ];

  # ── Identity ────────────────────────────────────────────────────────────────
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ── Dotfiles (symlinks vers /etc/nixos pour rester writables) ──────────────
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/quickshell";
  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/ghostty";
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar";
  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/rofi";
  xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/swaync";
  xdg.configFile."mango".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/mango";
  xdg.configFile."swaylock".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/swaylock/";
  xdg.configFile."starship.toml".source = ./starship.toml;

  home.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "wayland";

  # ── Packages ────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Media
    playerctl
    pavucontrol
    easyeffects
    tidal-hifi
    sox

    # Terminal & shell
    ghostty

    # Éditeur & outils dev
    neovim
    nixd # LSP Nix
    nixfmt # Formateur Nix
    clang-tools # LSP C/C++
    bash-language-server # LSP Bash
    vscode-langservers-extracted # LSP HTML/CSS/JSON
    stylua # Formateur Lua
    prettier # Formateur JS/MD/YAML
    qt6.qtdeclarative # Fourni qmlls (LSP qml)
    taplo # Formateur TOML
    shfmt # Formateur Shell
    nodejs

    # Window manager & desktop
    waybar
    swaybg # Wallpaper
    swaynotificationcenter # Notifications
    swayosd # OSD volume/luminosité
    rofi # Lanceur
    swayidle
    swaylock-effects

    #Quickshell (Projet)
    quickshell

    # Capture & presse-papiers
    grim
    slurp
    wl-clipboard
    wl-clip-persist # Garde le clipboard après fermeture
    cliphist # Historique presse-papiers

    # Apps
    discord
    bitwarden-desktop
    mangohud

    # IA
    claude-code
    pi-coding-agent

    # Système
    amdgpu_top # Monitoring GPU AMD
    networkmanagerapplet # Tray network
    btop

    # Fonts
    nerd-fonts.iosevka
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 48.85;
    longitude = 2.35;
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Amber";
    XCURSOR_SIZE = "24";
    QML_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.quickshell}/lib/qt-6/qml";
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

  wayland.windowManager.mango.enable = true;
}

{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Programs (system-wide) ──────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Steam, jeux, apps X11
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # Big Picture en gamescope (FSR, HDR)
    remotePlay.openFirewall = true; # Streaming Steam Remote Play
    localNetworkGameTransfers.openFirewall = true; # Transferts jeux entre PC
  };
  programs.zsh.enable = true;
  programs.firefox.enable = true;

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # nh — wrapper rebuild plus propre (nh os switch, nh search, nh clean)
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  # Compression de la swap en RAM (utile sans vraie swap disque)
  zramSwap.enable = true;

  # Swayosd — udev pour les permissions backlight/input
  services.udev.packages = [ pkgs.swayosd ];

  # ── Utilisateur ─────────────────────────────────────────────────────────────
  users.users.rayane = {
    isNormalUser = true;
    description = "Rayane";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # ── Réseau ──────────────────────────────────────────────────────────────────
  networking.hostName = "Rayane";
  networking.networkmanager.enable = true;

  # ── Localisation ────────────────────────────────────────────────────────────
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # ── Display & clavier ───────────────────────────────────────────────────────
  services.xserver.enable = true; # Nécessaire pour XWayland (Steam, etc.)
  services.displayManager.gdm.enable = true;
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  # ── Impression ──────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Sécurité ────────────────────────────────────────────────────────────────
  # PAM pour hyprlock (sinon le mdp n'est pas reconnu)
  security.pam.services.hyprlock = { };

  # ── Audio (PipeWire) ────────────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── GPU AMD ─────────────────────────────────────────────────────────────────
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # 32-bit pour les jeux
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.overdrive.enable = true; # Expose les sysfs OC pour LACT
  hardware.amdgpu.initrd.enable = true; # amdgpu chargé dès l'initrd (boot propre)

  # LACT — contrôle GPU AMD (clocks, fan curve, stats)
  services.lact.enable = true;

  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0dGKs7wMzfk5fhMaIoI7P/I4tFMQeA="
    ];
  };

  # Garbage collection automatique chaque semaine, garde 7 derniers jours
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # ── Variables d'environnement système ──────────────────────────────────────
  environment.sessionVariables = {
    # Active le backend Wayland natif de Proton (au lieu de XWayland) pour tous les jeux Steam
    PROTON_ENABLE_WAYLAND = "1";
  };

  # ── Packages système (les packages user vont dans home.nix) ────────────────
  environment.systemPackages = with pkgs; [
    wget
    tealdeer # tldr — pages d'aide concises
    wl-clipboard
    bat # cat avec syntax highlighting
    nix-output-monitor # nom — progression colorée des builds (utilisé par nh)
  ];

  # ── Disque jeux ─────────────────────────────────────────────────────────────
  fileSystems."/mnt/jeux" = {
    device = "/dev/disk/by-uuid/eaf01630-0390-47bc-8052-c056e1e5aedb";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
    ];
  };

  system.stateVersion = "25.11";
}

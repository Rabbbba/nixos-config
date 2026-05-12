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
  # programs.firefox.enable = true;  # remplacé par Zen Browser (cf home.nix + flake input zen-browser)

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # nh — wrapper rebuild plus propre (nh os switch, nh search, nh clean)
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  # nix-ld — permet de runner les binaires Linux génériques (releases GitHub,
  # binaires statiques téléchargés) directement, sans wrapper steam-run.
  # Ajouté pour codebase-memory-mcp (knowledge graph indexer pour pi).
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      glibc
      curl
      libxml2
      libxcrypt
    ];
  };

  # Compression de la swap en RAM (utile sans vraie swap disque)
  zramSwap.enable = true;

  # Le module zramSwap met swappiness à 100 par défaut. Trop agressif pour notre
  # usage (30 GiB de RAM, jeux + inference LLM en RAM/VRAM) : le kernel pré-swap
  # des pages "froides" qu'on retouche ensuite → major page faults = stutters.
  # 10 = ne swap que sous vraie pression mémoire.
  boot.kernel.sysctl."vm.swappiness" = 10;

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
  # overdrive.enable=true REMIS 2026-05-11 PM : ajoute amdgpu.ppfeaturemask=0xfffd7fff
  # qui DÉSACTIVE PP_GFXOFF. Sans ça, le GPU fait des transitions GFXOFF/GFX entre
  # chaque token decode (~10ms wake-up cost) → throughput plafonne à ~9 t/s sur
  # workloads intermittents (LLM). Avec PP_GFXOFF désactivé + profile_peak forcé,
  # le GPU reste vraiment stable au peak entre les tokens → ~25 t/s soutenu.
  hardware.amdgpu.overdrive.enable = true;
  hardware.amdgpu.initrd.enable = true; # amdgpu chargé dès l'initrd (boot propre)

  # Microcode CPU AMD (patches Zen 4 pour le 7800X3D — stabilité + perfs)
  hardware.cpu.amd.updateMicrocode = true;

  # LACT — GUI monitoring/OC GPU AMD
  services.lact.enable = true;

  # ── Bluetooth ───────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery level reporting
  };
  services.blueman.enable = true; # GUI manager + system tray applet

  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      # Cache binaire pour kernel cachyos (évite compile 40 min)
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0dGKs7wMzfk5fhMaIoI7P/I4tFMQeA="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
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
    # Active le wrapper Wayland des Electron NixOS-wrappés (Vesktop, etc.) — sinon
    # ils tournent en XWayland et le screen share via PipeWire renvoie un buffer vide.
    NIXOS_OZONE_WL = "1";
    # Hyprland (wlroots) en backend Vulkan natif — meilleur sur RDNA4 que l'OpenGL ES default
    WLR_RENDERER = "vulkan";
    # Optims RADV pour RDNA4 : sam = path optimisé Resizable BAR (déjà activé côté HW),
    # nv_ms = Mesh Shader optimisations (jeux récents), gpl = Graphics Pipeline Library
    # (réduit massivement les stutters de compilation shader, surtout UE5)
    RADV_PERFTEST = "sam,nv_ms,gpl";
  };

  # ── Packages système (les packages user vont dans home.nix) ────────────────
  environment.systemPackages = with pkgs; [
    wget
    tealdeer # tldr — pages d'aide concises
    wl-clipboard
    bat # cat avec syntax highlighting
    nix-output-monitor # nom — progression colorée des builds (utilisé par nh)
  ];

  # Kernel CachyOS BORE — scheduler optimisé pour latence (gaming, desktop interactif).
  # Source : xddxdd/nix-cachyos-kernel.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;

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

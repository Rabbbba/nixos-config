{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Programs (system-wide) ──────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.zsh.enable = true;

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  # runs generic linux binaries (github releases etc.) without a steam-run wrapper
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

  zramSwap.enable = true;

  # zramSwap defaults swappiness to 100 — too aggressive with 30 GiB RAM +
  # games/LLM: kernel pre-swaps pages we touch right after → stutters.
  boot.kernel.sysctl."vm.swappiness" = 10;

  # swayosd backlight/input udev rules
  services.udev.packages = [ pkgs.swayosd ];

  # ── User ───────────────────────────────────────────────────────────────────
  users.users.rayane = {
    isNormalUser = true;
    description = "Rayane";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # ── Network ────────────────────────────────────────────────────────────────
  networking.hostName = "Rayane";
  networking.networkmanager.enable = true;

  # ── Locale ─────────────────────────────────────────────────────────────────
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

  # ── Display & keyboard ─────────────────────────────────────────────────────
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  # ── Printing ───────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Security ───────────────────────────────────────────────────────────────
  # hyprlock rejects the password without this PAM service
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

  # ── AMD GPU ────────────────────────────────────────────────────────────────
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true; # 32-bit for games
  hardware.amdgpu.opencl.enable = true;
  # overdrive sets amdgpu.ppfeaturemask=0xfffd7fff → disables PP_GFXOFF, which
  # otherwise costs ~10ms wake-up per token on LLM workloads (9 → 25 t/s)
  hardware.amdgpu.overdrive.enable = true;
  hardware.amdgpu.initrd.enable = true;

  hardware.cpu.amd.updateMicrocode = true;

  services.lact.enable = true;

  # ── Bluetooth ───────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery level reporting
  };
  services.blueman.enable = true;

  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      # cachyos kernel binary cache — skips a ~40 min compile
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0dGKs7wMzfk5fhMaIoI7P/I4tFMQeA="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # ── System environment variables ───────────────────────────────────────────
  environment.sessionVariables = {
    PROTON_ENABLE_WAYLAND = "1";
    # without this, NixOS-wrapped Electron (vesktop) screenshare returns an empty buffer
    NIXOS_OZONE_WL = "1";
    # rdna4: vulkan beats the default OpenGL ES for wlroots
    WLR_RENDERER = "vulkan";
    # sam = resizable BAR, nv_ms = mesh shaders, gpl = pipeline library (UE5 stutters)
    RADV_PERFTEST = "sam,nv_ms,gpl";
  };

  # ── System packages (user packages live in home.nix) ───────────────────────
  environment.systemPackages = with pkgs; [
    wget
    tealdeer
    wl-clipboard
    bat
    nix-output-monitor # nom — used by nh
  ];

  # CachyOS BORE — latency-tuned scheduler (xddxdd/nix-cachyos-kernel)
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;

  # ── Games disk ─────────────────────────────────────────────────────────────
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

{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10; # ne garder que les 10 dernières générations dans le menu de boot
  boot.loader.efi.canTouchEfiVariables = true;

  # /tmp on tmpfs — RAM-backed builds, faster nix/cmake intermediates
  boot.tmp.useTmpfs = true;

  # ── Programs (system-wide) ──────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.zsh.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true; # trash, MTP, network mounts
  services.tumbler.enable = true; # thumbnail daemon

  programs.gamemode.enable = true; # enableRenice is on by default (cap_sys_nice wrapper)

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 10"; # ne conserver que les 10 dernières générations (tous profils)
    };
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

  # zramSwap defaults swappiness to 100 — too aggressive with 30 GiB RAM: the
  # kernel pre-swaps pages we touch right after, which stutters under games.
  boot.kernel.sysctl."vm.swappiness" = 10;

  # tidal-hifi binds its API on 47836, which sits inside the kernel's ephemeral
  # port range — outbound sockets occasionally steal it, breaking bind().
  boot.kernel.sysctl."net.ipv4.ip_local_reserved_ports" = "47836";

  # udev rules: swayosd (backlight/input), rivalcfg (SteelSeries mice HID),
  # headsetcontrol (SteelSeries headsets HID)
  services.udev.packages = [
    pkgs.swayosd
    pkgs.rivalcfg
    pkgs.headsetcontrol
  ];

  # ── User ───────────────────────────────────────────────────────────────────
  users.users.rayane = {
    isNormalUser = true;
    description = "Rayane";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input" # rivalcfg HID access (SteelSeries mice udev rule uses GROUP="input")
      "docker" # manage containers without sudo (grants root-equivalent access)
    ];
  };

  # ── Network ────────────────────────────────────────────────────────────────
  networking.hostName = "Rayane";
  networking.networkmanager.enable = true;

  # Steam P2P / matchmaking inbound. remotePlay/localNetworkGameTransfers only
  # open a narrow subrange; TWW3 (and other Steamworks P2P titles) also need the
  # game-traffic range plus the Steam Datagram Relay ports, otherwise a direct
  # join falls back with "No response from host".
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 27000;
      to = 27100;
    }
  ];
  networking.firewall.allowedUDPPorts = [
    3478
    4379
    4380
    27015
  ];
  networking.firewall.allowedTCPPorts = [
    27015
    27036
  ];

  # Encrypted DNS via a local dnscrypt-proxy speaking DoH to Mullvad (adblock
  # variant: blocks ads + trackers). resolv.conf is pinned to 127.0.0.1 and
  # NetworkManager is kept out of DNS (dns=none). systemd-resolved is left off on
  # purpose: NM pushes the ISP's DHCP DNS to resolved over D-Bus regardless of
  # dns=none, leaking plaintext queries per-link — a local forwarder sidesteps it.
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];
      server_names = [ "mullvad-adblock" ];
      # Stamp embeds the resolver IP, so no bootstrap DNS is needed to reach it.
      static.mullvad-adblock.stamp = "sdns://AgMAAAAAAAAACzE5NC4yNDIuMi4zABdhZGJsb2NrLmRucy5tdWxsdmFkLm5ldAovZG5zLXF1ZXJ5";
    };
  };
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];

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
  # Pas de services.xserver.enable : session 100 % Wayland. Xwayland vient de
  # programs.hyprland.xwayland.enable, le greeter de greetd (TTY), le layout
  # Wayland de Hyprland (kb_layout) et le TTY de console.keyMap ci-dessous.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd 'uwsm start hyprland.desktop'";
        user = "greeter";
      };
    };
  };
  console.keyMap = "fr";

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
  # amdgpu.ppfeaturemask=0xfffd7fff — unlocks the clock/voltage controls LACT
  # drives. Side effect: PP_GFXOFF is disabled, so the GPU skips its deep idle
  # state (costs a few watts at rest, removes the wake-up latency on it).
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
      "https://rabbbba-nixos.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0dGKs7wMzfk5fhMaIoI7P/I4tFMQeA="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "rabbbba-nixos.cachix.org-1:vNaCUQyAOs64wPY9n/U2RF9kipscTBmGphdKA/un5pg="
    ];
  };

  # GC géré par programs.nh.clean (--keep 10) — voir le bloc programs.nh ci-dessus

  # hardlink identical store paths — silent disk savings over time
  nix.optimise.automatic = true;

  nixpkgs.config = {
    allowUnfree = true;

    # electron churne à chaque bump nixpkgs (desktop client, pas un service
    # exposé) : on autorise toutes ses versions au lieu de re-pin à chaque
    # --update. allowInsecurePredicate REMPLACE permittedInsecurePackages, donc
    # pnpm (build-time only, vesktop-pnpm-deps) est géré ici aussi.
    allowInsecurePredicate =
      pkg:
      let
        name = pkgs.lib.getName pkg;
      in
      name == "electron" || name == "pnpm";
  };

  # ── System environment variables ───────────────────────────────────────────
  environment.sessionVariables = {
    # PROTON_ENABLE_WAYLAND is opt-in per-game via launch options — global breaks
    # Steam overlay injection (X11-only hook can't reach Wayland-native clients).
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
    rivalcfg # SteelSeries mice (Aerox 5 Wireless): sleep timer, DPI, RGB
    headsetcontrol # SteelSeries headsets (Arctis Nova Pro Wireless): battery, sidetone, inactive-time
    tmux
    uv
  ];

  # CachyOS BORE — latency-tuned scheduler (xddxdd/nix-cachyos-kernel)
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore;

  # Cap USB HID mouse polling at 500 Hz — works around UE5 stutter bug on Proton
  # (ValveSoftware/Proton#8391). Value = polling interval in ms (2 ms = 500 Hz).
  boot.kernelParams = [ "usbhid.mousepoll=2" ];

  # Motherboard sensors (NCT6687D): its native driver is out-of-tree, but
  # nct6683 drives the chip when forced. Gives fan RPM and the supply rails,
  # which k10temp/amdgpu don't expose. Labels and voltage scaling are wrong
  # under this driver — only the trends are meaningful.
  boot.kernelModules = [ "nct6683" ];
  boot.extraModprobeConfig = "options nct6683 force=1";

  # ── Games disk ─────────────────────────────────────────────────────────────
  fileSystems."/mnt/jeux" = {
    device = "/dev/disk/by-uuid/eaf01630-0390-47bc-8052-c056e1e5aedb";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
    ];
  };

  # weekly scrub catches silent btrfs corruption on the games partition
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/mnt/jeux" ];
  };

  # ── Misc services ──────────────────────────────────────────────────────────
  # firmware updates via LVFS (BIOS, SSD, peripherals)
  services.fwupd.enable = true;

  # ── Containers ─────────────────────────────────────────────────────────────
  # Docker for self-hosted services run from upstream compose files.
  virtualisation.docker.enable = true;

  system.stateVersion = "25.11";
}

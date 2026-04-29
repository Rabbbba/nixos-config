# NixOS Config — Rayane

NixOS flake-based configuration for a single AMD desktop running **Mango WM** on Wayland.

## Stack

| Category | Tool |
|---|---|
| OS | NixOS (unstable) |
| Window Manager | [Mango WM](https://github.com/mangowm/mango) |
| Bar | Waybar |
| Terminal | Foot |
| Editor | Neovim (NvChad) |
| Launcher | Rofi |
| Notifications | Swaync |
| Shell | Fish |
| Font | Iosevka Nerd Font |

## Install

### Fresh NixOS install

After installing NixOS, clone this repo and replace the default config:

```bash
sudo rm -rf /etc/nixos
sudo git clone https://github.com/Rayane-Bensalah/nixos-config /etc/nixos
sudo nixos-rebuild switch
```

That's it. Home-manager will install all packages and link all configs automatically.

### Update

```bash
sudo nixos-rebuild switch
```

### Update flake inputs (nixpkgs, home-manager, mango)

```bash
sudo nix flake update /etc/nixos
sudo nixos-rebuild switch
```

## Structure

```
/etc/nixos/
├── flake.nix              # Entry point, inputs (nixpkgs, home-manager, mango)
├── configuration.nix      # System config (boot, network, services, GPU)
├── home.nix               # User config (packages, dotfiles, git, mango)
├── hardware-configuration.nix  # Auto-generated, do not edit
├── nvim/                  # Neovim config (NvChad)
├── foot/                  # Foot terminal config
├── waybar/                # Waybar config
├── rofi/                  # Rofi config
├── swaync/                # Swaync config
└── mango/                 # Mango WM config
```

## Key bindings (Mango defaults)

| Key | Action |
|---|---|
| `Alt + Enter` | Open terminal (foot) |
| `Alt + Space` | Open launcher (rofi) |
| `Alt + Q` | Close window |
| `Alt + ←/→/↑/↓` | Move focus |
| `Ctrl + 1-9` | Switch tag |
| `Alt + 1-9` | Move window to tag |
| `Super + R` | Reload config |
| `Super + M` | Quit Mango |

## Maintenance

```bash
# Garbage collect old generations
sudo nix-collect-garbage -d

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

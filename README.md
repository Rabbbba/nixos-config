# NixOS Config — Rayane

NixOS flake-based configuration for a single AMD desktop running **Mango WM** on Wayland.

## Stack

| Category | Tool |
|---|---|
| OS | NixOS (unstable) |
| Window Manager | [Mango WM](https://github.com/mangowm/mango) |
| Bar | Waybar |
| Terminal | Ghostty |
| Editor | Neovim (NvChad) |
| Launcher | Rofi |
| Notifications | Swaync |
| Shell | Zsh + Starship |
| Audio | PipeWire + EasyEffects |
| Screenshots | grim + slurp |
| OSD (volume/brightness) | swayosd |
| Cursor | Bibata-Modern-Amber |
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
├── starship.toml          # Starship prompt (gruvbox-rainbow)
├── nvim/                  # Neovim config (NvChad)
├── ghostty/               # Ghostty terminal config
├── waybar/                # Waybar config + style
├── rofi/                  # Rofi launcher + theme
├── swaync/                # Swaync notification center
├── mango/                 # Mango WM config (modular: binds, rules, monitors...)
│   └── scripts/           # Helper scripts (reload, etc.)
└── wallpapers/            # Wallpapers per monitor
```

## Key bindings (Mango)

### Apps
| Key | Action |
|---|---|
| `Alt + Enter` | Terminal (ghostty) |
| `Alt + Space` | Launcher (rofi) |
| `Super + B` | Firefox |

### Window management
| Key | Action |
|---|---|
| `Alt + Q` | Close window |
| `Alt + ←/→/↑/↓` | Move focus |
| `Super + Shift + ←/→/↑/↓` | Swap windows |
| `Alt + \` | Toggle floating |
| `Alt + F` | Fullscreen |
| `Alt + Tab` | Overview |

### Layouts
| Key | Action |
|---|---|
| `Super + T` | Tile |
| `Super + M` | Monocle |
| `Super + V` | Vertical grid |
| `Super + Shift + V` | Vertical scroller |
| `Super + N` | Cycle layouts |

### Tags / Workspaces
| Key | Action |
|---|---|
| `Ctrl + 1-9` | Switch tag |
| `Alt + 1-9` | Move window to tag |
| `Super + ←/→` | Previous / next tag |
| `Alt + Shift + ←/→` | Focus monitor |

### System
| Key | Action |
|---|---|
| `Super + R` | Reload Mango config |
| `Super + Shift + R` | Restart Waybar |
| `Super + Shift + M` | Quit Mango |
| `Super + S` | Screenshot region → file |
| `Super + Ctrl + S` | Screenshot region → clipboard |
| Volume / Brightness | Hardware keys via swayosd |

## Maintenance

```bash
# Garbage collect old generations
sudo nix-collect-garbage -d

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

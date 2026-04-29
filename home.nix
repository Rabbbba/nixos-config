{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.mango.hmModules.mango ];
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/ghostty";
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar";
  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/rofi";
  xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/swaync";
  xdg.configFile."mango".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/mango";

  home.packages = with pkgs; [
    ghostty
    neovim
    nixfmt
    clang-tools
    bash-language-server
    stylua
    vscode-langservers-extracted
    prettier
    taplo
    shfmt
    fish
    swaybg
    waybar

    swaynotificationcenter
    nerd-fonts.iosevka
    nixd
    rofi
    discord
    pi-coding-agent
    nodejs
    claude-code
    bitwarden-desktop
    wl-clip-persist
    cliphist
    networkmanagerapplet
    swayosd
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Rayane";
    settings.user.email = "rayane.bensalah@proton.me";
  };

  wayland.windowManager.mango = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;

}

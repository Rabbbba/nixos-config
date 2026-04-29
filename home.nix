{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.mango.hmModules.mango ];
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";
  xdg.configFile."foot".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/foot";
  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/waybar";
  xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/rofi";
  xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/swaync";


  home.packages = with pkgs; [
    nixfmt
    clang-tools
    hyprls
    bash-language-server
    stylua
    vscode-langservers-extracted
    prettier
    taplo
    shfmt
    fish
    foot
    swaybg
    waybar
    swaynotificationcenter
    nerd-fonts.iosevka
    nixd
    rofi
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Rayane";
    settings.user.email = "rayane.bensalah@proton.me";
  };

    wayland.windowManager.mango = {
    enable = true;
  };

}

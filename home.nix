{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.mango.hmModules.mango ];
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nvim";

  home.packages = with pkgs; [
    nixfmt-rfc-style
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

{ config, pkgs, ... }:

{
  home.username = "rayane";
  home.homeDirectory = "/home/rayane";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Rayane";
    userEmail = "rayane.bensalah@proton.me";
  };
}

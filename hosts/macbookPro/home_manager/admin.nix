{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../home-managerModules/lazyvim.nix  # We'll create this next
  ];
  
  # Basic Home Manager configuration
  home = {
    username = "admin";
    homeDirectory = "/Users/admin";
    stateVersion = "23.11";
  };
  
  programs = {
    zsh = {
        enable = true;
        oh-my-zsh.enable = true;
    };
    lazyvim.enable = true; 
  };
}
{ config, pkgs, lib, ... }:

let
  lazyvimStarter = pkgs.fetchFromGitHub {
    owner = "LazyVim";
    repo = "starter";
    rev = "aa6a3d4d6cc8d6d5e5c4f3b3a1a7f3e5e4d7c5b3"; # Update to latest commit
    hash = ""; # Will be filled automatically
  };
in

{
  options.lazyvim.enable = lib.mkEnableOption "Enable LazyVim";

  config = lib.mkIf config.lazyvim.enable {
    home.packages = with pkgs; [
      neovim
      ripgrep
      fd
      lazygit
    ];

    xdg.configFile."nvim" = {
      source = lazyvimStarter;
      recursive = true;
    };
  };
}
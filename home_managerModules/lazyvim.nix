{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.lazyvim;
  lazyvimStarter = pkgs.fetchFromGitHub {
    owner = "LazyVim";
    repo = "starter";
    rev = "803bc181d7c0d6d5eeba9274d9be49b287294d99"; # Update to latest commit
    # sha256 = lib.fakeSha256;
    # hash = lib.fakeHash;
    sha256 = "QrpnlDD4r1X4C8PqBhQ+S3ar5C+qDrU1Jm/lPqyMIFM=";
  };
in

{
  options.lazyvim = {
    enable = mkEnableOption "LazyVim configuration";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      
      extraPackages = with pkgs; [
        # Language servers and tools
        lua-language-server
        nil # Nix language server
        ripgrep
        fd
        
      ];
    };

    # Ensure the Neovim configuration directory exists
    home.file.".config/nvim" = {
      source = lazyvimStarter;
      recursive = true;
    };
  };
}
{ config, pkgs, lib, ... }: 

{
  options = {
    terminalDefaults.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.terminalDefaults.enable {
    environment.systemPackages = with pkgs; [
      htop
      ranger
      neovim
      tmux
      alacritty
    ];


    # Optional program-specific configurations
    # programs.tmux.enable = true;
  };
}

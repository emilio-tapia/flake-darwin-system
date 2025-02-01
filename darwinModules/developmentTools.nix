{ config, pkgs, lib, ... }: 

{
  options = {
    developmentTools.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.developmentTools.enable {
    environment.systemPackages = with pkgs; [
      git
      fnm
      nodejs
      pnpm
      python313
      temurin-jre-bin-8
      virtualenv
      # pyenv
    ];


    # Optional program-specific configurations
    # programs.tmux.enable = true;
  };
}

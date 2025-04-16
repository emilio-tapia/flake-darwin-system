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
      python3Packages.pip
      temurin-jre-bin-8
      virtualenv
      docker_26
      # pyenv
    ];


    # Optional program-specific configurations
    # programs.tmux.enable = true;
  };
}

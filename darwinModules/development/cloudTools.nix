{ config, pkgs, lib, ... }: 

{
  options = {
    cloudTools.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.cloudTools.enable {
    environment.systemPackages = with pkgs; [
        awscli2
    ];
  };
}

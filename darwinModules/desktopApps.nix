{ config, pkgs, lib, ... }: 

{
  options = {
    desktopApps.enable = lib.mkEnableOption "Enable installation of common desktop applications";
  };

  config = lib.mkIf config.desktopApps.enable {
    environment.systemPackages = with pkgs; [
      vlc-bin             # Media player
    #   firefox         # Web browser
    #   thunderbird     # Email client
      dbeaver-bin         # Universal database tool _ version 24.3
      # brave
      # slack
      audacity
      # bitwarden-desktop
    #   bitwarden-cli
    #   keepassxc
      # keepass
      # zoom-us
      xld
      vscode
      #   teams
      # archi
      # camunda-modeler # didn't work intel
      # android-studio
      # appcleaner
      # cool-retro-term # didn't work intel
    ];
  };
}

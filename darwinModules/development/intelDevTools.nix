{ config, pkgs, lib, ... }: 

{
  options = {
    intelDevTools.enable = lib.mkEnableOption "Enable installation of intel development tools";
  };

  config = lib.mkIf config.intelDevTools.enable {
    environment.systemPackages = with pkgs; [
      # JAVA
      temurin-bin-8
    ];

  # environment.variables.JAVA_HOME = "${pkgs.temurin-bin-8}";

  };
}

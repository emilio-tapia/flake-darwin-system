{ config, pkgs, lib, ... }: 

{
  options = {
    siliconDevTools.enable = lib.mkEnableOption "Enable installation of silicon development tools";
  };

  config = lib.mkIf config.intelDevTools.enable {
    environment.systemPackages = with pkgs; [
    ];

  # environment.variables.JAVA_HOME = "${pkgs.temurin-bin-8}";

  };
}

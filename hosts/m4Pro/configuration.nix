{ config, pkgs, lib, ... }:

{

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # macbookPro-specific configuration
  networking.hostName = "macbookPro";

  # Enable system defaults
  hardware.enable = true;
  darwinConfiguration.enable = true;
  systemDefaults.enable = true;

  # 
  fontPackage.enable = true;
  terminalDefaults.enable = true;
  homeBrew.enable = true;


  # Enable specific modules
  cloudTools.enable = true;
  desktopApps.enable = true;
  developmentTools.enable = true;
  # module2.enable = false;
}

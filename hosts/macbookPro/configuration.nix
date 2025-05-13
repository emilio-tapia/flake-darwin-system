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
  intelDevTools.enable = true;

  # Enable specific modules
  globalDevTools.enable = true;
  fontPackage.enable = true;
  terminalTools.enable = true;
  homeBrew.enable = true;
  cloudTools.enable = true;
  desktopApps.enable = true;
}

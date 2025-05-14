{ config, pkgs, lib, ... }:

{

  # macbookPro-specific configuration
  networking.hostName = "macbookPro";

  # Enable system defaults
  hardware.enable = true;
  darwinConfiguration.enable = true;
  systemDefaults.enable = true;
  intelDevTools.enable = true;

  # Enable specific modules
  devTools.enable = true;
  fontPackage.enable = true;
  terminalTools.enable = true;
  homeBrew.enable = true;
  cloudTools.enable = true;
  desktopApps.enable = true;
}

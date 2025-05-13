{ config, pkgs, lib, ... }:

{

  # macbookPro-specific configuration
  networking.hostName = "m4Pro";
  nix.enable = false; #enable homebrew in apple silicon

  # Enable system defaults
  hardware.enable = true;
  darwinConfiguration.enable = true;
  systemDefaults.enable = true;
  siliconDevTools.enable = true;

  # Enable specific modules
  globalDevTools.enable = true;
  fontPackage.enable = true;
  terminalTools.enable = true;
  homeBrew.enable = true;
  cloudTools.enable = true;
  desktopApps.enable = true;
}

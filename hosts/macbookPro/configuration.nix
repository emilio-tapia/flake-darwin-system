{ config, pkgs, lib, ... }:

{
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
  lazyVim.enable = true;


  # Enable specific modules
  cloudTools.enable = true;
  desktopApps.enable = true;
  developmentTools.enable = true;
  # module2.enable = false;
  # module3.enable = true;
}

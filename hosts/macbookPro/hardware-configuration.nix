{ self, config, pkgs, lib, ... }: 

{
  options = {
    hardware.enable = lib.mkEnableOption "Enable hardware-specific macOS configurations.";
  };

  config = lib.mkIf config.hardware.enable {

    # Set Git commit hash for darwin-version
    system.configurationRevision = self.rev or self.dirtyRev or null;

    # State version for backwards compatibility
    system.stateVersion = 5;

    # Platform configuration
    nixpkgs.hostPlatform = "x86_64-darwin";
  };
}

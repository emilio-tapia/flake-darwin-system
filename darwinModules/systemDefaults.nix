{ self, config, pkgs, lib, ... }:

{
  options = {
    systemDefaults.enable = lib.mkEnableOption "Enable system-wide macOS default configurations.";
  };

  config = lib.mkIf config.systemDefaults.enable {


    environment.systemPackages = with pkgs; [
      nix-prefetch-github
    ];


    # Enable alternative shell support in nix-darwin
    programs.zsh.enable = true; # Default shell on macOS

    system.defaults = {
      dock.autohide = false;
      dock.mru-spaces = false;
      dock.show-recents = false; # Don't show recent applications in the Dock
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "Nlsv"; # List view in Finder
      loginwindow.LoginwindowText = "Emilio";
      screencapture.location = "~/Pictures/screenshots";
      screensaver.askForPasswordDelay = 10;
    };

    # Keyboard
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToEscape = true;

    # Add ability to used TouchID for sudo authentication
    # security.pam.enableSudoTouchIdAuth = true;

  };
}

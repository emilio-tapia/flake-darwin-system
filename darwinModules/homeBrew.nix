{ self, config, pkgs, lib, ... }:

{
  options = {
    homeBrew.enable = lib.mkEnableOption "Enable system-wide macOS default configurations.";
  };

  config = lib.mkIf config.homeBrew.enable {
    homebrew = { 
      enable = true;
      onActivation = {
        # autoUpdate = false;
        cleanup = "zap";
        upgrade = true;
      };

      casks = [
        "iina"
        "httpie"
        "bruno"
        # "dbschema" # app runtime error in intel
        # "cursor"
        # "google-chrome"
        # "figma"
        # "sync"
        # "google-drive"
        "omnidisksweeper"
        "transmission"
        "android-file-transfer"
        # "focusrite-control"
        "rightfont"
        # "sf-symbols"
        "sourcetree"
        "camunda-modeler"
        "cool-retro-term"
      ];

      caskArgs = {
        appdir = "~/Applications";
        # require_sha = true;
      };
      
      brews = [
        "jenv"
        "mas"
        # "pnpm"
        "tree"
        # "postgresql@16"
      ];

      masApps = {
        "EZVIZ for Mac" = 1594552558;
        "SnippetsLab" = 1006087419;
        "WhatsApp Messenger" = 310633997;
        "Mini Calendar" = 1088779979;
      };
    };
  };
}
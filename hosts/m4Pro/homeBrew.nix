{ self, config, pkgs, lib, ... }:

with lib;

{
  options = {
    siliconHomeBrew.enable = lib.mkEnableOption "Enable homebrew M4 Pro default configurations.";
  };

  config = lib.mkIf config.siliconHomeBrew.enable {
    homebrew = { 
      enable = true;
      onActivation = {
        # autoUpdate = false;
        cleanup = "zap";
        upgrade = true;
      };

      # brewPrefix = "/opt/homebrew/bin";

      # global = {
      #   brewfile = true;        # Exporta el Brewfile de nix-darwin a una ruta fija y lo usa
      #   lockfiles = false;      # Previene errores de escritura al intentar generar lockfiles en la store
      # };

      casks = [
        "iina"
        "httpie"
        "bruno"
        # "dbschema" # app runtime error in intel
        "cursor"
        "google-chrome"
        "figma"
        # "sync"
        "google-drive"
        "omnidisksweeper"
        "transmission"
        "android-file-transfer"
        "focusrite-control"
        "rightfont"
        "sf-symbols"
        "sourcetree"
        "camunda-modeler"
        "cool-retro-term"
        # "dbeaver-community" # installed by nix
        "tradingview"
        # "appcleaner" # installed by nix
        "sourcetree"
        "obsidian"
        "docker"
        # "poppler"
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
        # "fzf" #installed in home-manager
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
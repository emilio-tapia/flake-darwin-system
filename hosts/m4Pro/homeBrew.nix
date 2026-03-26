{ self, config, pkgs, lib, ... }:

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
        "httpie-desktop"
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
        "obsidian"
        "docker-desktop"
        "losslesscut"
        "handbrake-app"
        
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
        "poppler"
        "llmfit"
        "gromgit/brewtils/taproom"
        "domcyrus/rustnet/rustnet"
        # "gitversion"
        "mikalv/mcdu/mcdu"
        # "chojs23/tap/ec" # native 3-way git conflict resolver.
        "models" #TUI for browsing AI models and coding agents
        "whosthere" #local area network (LAN) discovery tool with a modern TUI interface.
        "mole" #Deep clean and optimize your Mac.
        # "marcus/tap/sidecar" #TUI dashboard for AI coding agents.
        # "jordond/tap/jolt" #A beautiful TUI battery and energy monitor for your terminal.
        "snitch" #A TUI for inspecting network connections, like netstat for humans.
        # "arimxyer/tap/aic" #Fetch the latest changelogs for popular AI coding assistants.
        # "andrewmd5/tap/dawn" #distraction-free writing environment. draft anything, write now.
        "bookokrat" # terminal EPUB / PDF ebook reader.
        "dnspyre" #CLI tool for a high QPS DNS benchmark.
        # "torra" #Maniacsan/homebrew-torrra/torrra
        "cronboard" #A terminal tool for managing cron jobs locally and on servers.
        "gittype" #A terminal code-typing game that turns your source code into typing challenges.
        # "miklosn/tap/cmdperf" #Benchmark and compare shell commands interactively.
        # "Fguedes90/tap/lazycelery" #A TUI for monitoring and managing Celery workers and tasks.
        # "conikeec/tap/mcp-probe" #Advanced MCP Protocol Debugger & Interactive TUI.
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
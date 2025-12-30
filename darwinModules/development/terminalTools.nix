{ config, pkgs, lib, ... }: 

{
  options = {
    terminalTools.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.terminalTools.enable {
    environment.systemPackages = with pkgs; [
      ranger
      
      mprocs #TUI tool to run multiple commands in parallel

      # CPU STATS
      #below # resource monitor for modern Linux systems (only for linux)
      # CLI utilities
      tokei #count code statistics
      rnr #batch rename files and directories
      kondo #clean unneed files
      jless #cli json viewer
      hyperfine #Command-line benchmarking tool
      pass #synchronizes passwords securely




      # Generic file processors
      pdfcpu #pdf tools
      htmlq #extract html part based on queries
      # poppler #PDF rendering library

      # DB activity
      pg_activity #PostgreSQL server activity monitoring
    ];


    # Optional program-specific configurations
    # programs.tmux.enable = true;
    programs = {
      zsh ={
        enable = true;
      };
    };
  };
}

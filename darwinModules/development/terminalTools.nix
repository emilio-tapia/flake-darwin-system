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
      btop #htop

      # CLI utilities
      tokei #count code statistics
      rnr #batch rename files and directories
      kondo #clean unneed files
      jless #cli json viewer

      # Generic file processors
      pdfcpu #pdf tools
      htmlq #extract html part based on queries
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

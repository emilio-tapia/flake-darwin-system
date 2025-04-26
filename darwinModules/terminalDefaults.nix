{ config, pkgs, lib, ... }: 

{
  options = {
    terminalDefaults.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.terminalDefaults.enable {
    environment.systemPackages = with pkgs; [
      htop
      ranger
      tmux
      alacritty
      cheat
      pdfcpu #pdf tools
      tokei #count code statistics
      mprocs #TUI tool to run multiple commands in parallel
      rnr #batch rename files and directories
      kondo #clean unneed files
      jless #cli json viewer
      htmlq #extract html part based on queries
      atuin #shell history
      yazi #terminal file manager
      btop #htop
      xh #fast tool for sending HTTP requests
      hurl #performs HTTP requests defined in plain text format
      graphviz #Graph visualization tools
      plantuml #Draw UML diagrams using human readable text description

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

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
      pdfgrep #Commandline utility to search text in PDF files
      # mcat #cat command for documents/images/videos and more
      # poppler #PDF rendering library

      # DB activity
      pg_activity #PostgreSQL server activity monitoring

      #Git
      lazygit

      #JSON
      jiq #Interactive JSON query tool using jq expressions

      jrnl #stores your journal in a plain text file
      doxx #Terminal document viewer for .docx files
      # xleak #Terminal Excel viewer with an interactive TUI
      kakoune #Vim inspired text editor
      mergiraf #Mergiraf can solve a wide range of Git merge conflicts. 
      cariddi #Crawler for URLs and endpoints
      so #TUI to StackExchange network
      # tldx #Domain availability research tool
      ticker #Terminal stock ticker with live updates and position tracking
      tldr #Simplified and community-driven man pages
      # pngoptimizer #PNG optimizer and converter
      eza #Modern, maintained replacement for ls
      # percollate #tool to turn web pages into readable PDF, EPUB, HTML, or Markdown docs (depends on chromium, not available on aarch64-darwin)
      # lazyssh #Terminal-based SSH manager (not yet in nixpkgs-25.05, only unstable)
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

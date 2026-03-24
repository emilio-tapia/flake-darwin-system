{ config, pkgs, lib, user, ... }:

{
  options = {
    devTools.enable = lib.mkEnableOption "Enable installation of global development tools";
  };

  config = lib.mkIf config.devTools.enable {
    environment.systemPackages = with pkgs; [
      opencode #AI coding agent built for the terminal
      # claude-code #Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
      # claude-monitor #Real-time Claude Code usage monitor (not yet in nixpkgs-25.05, only unstable)
      # claude-code-router #Tool to route Claude Code requests to different models and customize any request (not yet in nixpkgs-25.05, only unstable)
      git
      # gitlogue
      devenv
      pgcli #Command-line interface for PostgreSQL
      zizmor #Tool for finding security issues in GitHub Actions setups

      #SEARCH
      ast-grep #Fast and polyglot tool for code searching, linting, rewriting at large scale

      # NODE
      fnm
      nodejs
      pnpm

      # PYTHON
      python313
      python3Packages.pip
      virtualenv

      # AUTOMATION
      # n8n

      # CONTAINER
      # docker #homebrew
      # docker-compose #homebrew
      oxker #view & control docker containers

      #SECRETS
      doppler #CLI for interacting with your Doppler Enclave secrets and configuration

      # DATA VIZUALIZATION
      graphviz #Graph visualization tools
      plantuml #Draw UML diagrams using human readable text description
      mermaid-cli #Generation of diagrams from text

      # THIRD PARTY
      google-clasp #Develop Apps Script Projects locally

      # API TOOLS
      xh #fast tool for sending HTTP requests
      hurl #performs HTTP requests defined in plain text format
    ];

  # environment.variables.JAVA_HOME = "${pkgs.temurin-bin-8}";


    system.activationScripts.preActivation = {
      enable = true;
      text = ''
        if [ ! -d "/var/lib/postgresql/" ]; then
          echo "creating PostgreSQL data directory..."
          sudo mkdir -m 750 -p /var/lib/postgresql/
          chown -R ${user}:staff /var/lib/postgresql/
        fi
      '';
    };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initdbArgs = [
      "-U ${user}"            # Initialize with host user
      "--pgdata=/var/lib/postgresql/16"
      "--auth=trust"
      "--no-locale"
      "--encoding=UTF8"
    ];
  };

    launchd.user.agents.postgresql.serviceConfig = {
      UserName = user;     # Run service as host user
      GroupName = "staff";
      StandardErrorPath = "/tmp/postgres.error.log";
      StandardOutPath = "/tmp/postgres.log";
    };
  };
}

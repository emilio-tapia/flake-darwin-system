{ config, pkgs, lib, ... }: 

{
  options = {
    globalDevTools.enable = lib.mkEnableOption "Enable installation of global development tools";
  };

  config = lib.mkIf config.globalDevTools.enable {
    environment.systemPackages = with pkgs; [
      git

      # NODE
      fnm
      nodejs
      pnpm

      # JAVA
      temurin-bin-8

      # PYTHON
      python313
      python3Packages.pip
      virtualenv

      # CONTAINER
      docker_26

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
          chown -R admin:staff /var/lib/postgresql/
        fi
      '';
    };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    initdbArgs = [
      "-U admin"            # Initialize with 'admin' user
      "--pgdata=/var/lib/postgresql/16"
      "--auth=trust"
      "--no-locale"
      "--encoding=UTF8"
    ];
  };

    launchd.user.agents.postgresql.serviceConfig = {
      UserName = "admin";     # Run service as 'admin' user
      GroupName = "staff";
      StandardErrorPath = "/tmp/postgres.error.log";
      StandardOutPath = "/tmp/postgres.log";
    };
  };
}

{ config, pkgs, lib, ... }: 

{
  options = {
    developmentTools.enable = lib.mkEnableOption "Enable installation of development tools such as tmux, alacritty, git, nodejs, and python.";
  };

  config = lib.mkIf config.developmentTools.enable {
    environment.systemPackages = with pkgs; [
      git
      fnm
      nodejs
      pnpm
      python313
      python3Packages.pip
      temurin-jre-bin-8
      virtualenv
      docker_26
      # postgresql_16
    ];
    # Optional program-specific configurations
    # programs.tmux.enable = true;


    # 1. Service declaration (mandatory)
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_16;
  #   dataDir = "/var/lib/postgresql/16";
    
  #   # Modern settings format (attribute set)
  #   settings = {
  #     unix_socket_directories = "/tmp";
  #     # Add other PostgreSQL.conf settings here as key-value pairs
  #     # shared_buffers = "256MB";
  #     # max_connections = 100;
  #   };
  # };

  #   system.activationScripts.postgresUserSetup = {
  #   enable = true;
  #   text = ''
  #     # Create 'postgres' group if it doesn't exist
  #     # if ! dscl . -read /Groups/postgres >/dev/null 2>&1; then
  #       echo "Creating 'postgres' group..."
  #       sudo dscl . -create /Groups/postgres
  #       sudo dscl . -create /Groups/postgres gid 502
  #     # fi

  #     # Create 'postgres' user if it doesn't exist
  #     # if ! dscl . -read /Users/postgres >/dev/null 2>&1; then
  #       echo "Creating 'postgres' user..."
  #       sudo dscl . -create /Users/postgres
  #       sudo dscl . -create /Users/postgres UserShell /usr/bin/false
  #       sudo dscl . -create /Users/postgres UniqueID 502
  #       sudo dscl . -create /Users/postgres PrimaryGroupID 502  # Match group ID
  #     # fi
  #   '';
  # };

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

{

  description = "Emilio Mac Nix-Darwin Flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    # nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager.url = "github:nix-community/home-manager"; # Reference to home-manager for user-level configurations
    home-manager.url = "github:nix-community/home-manager/release-24.11"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    devenv.url = "github:cachix/devenv/latest";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    gitignore.url = "github:hercules-ci/gitignore.nix";
    mac-app-util.url = "github:hraban/mac-app-util";
    lazyvim = {
      url = "github:LazyVim/starter";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, devenv, flake-utils, gitignore, ... }@inputs:
  let

    # Common configuration for all Darwin systems
    darwinModules = [
      home-manager.darwinModules.home-manager
      mac-app-util.darwinModules.default
      nix-homebrew.darwinModules.nix-homebrew
      ./darwinModules/systemDefaults.nix
      ./darwinModules/desktopApps.nix
      ./darwinModules/fontPackage.nix
      # ({ config, ... }: {
        # Security-hardened Nix configuration
        # nix.settings = {
          # allowed-users = ["emilio" "admin"];
          # sandbox = true;
        # };
      # })
    ];

    # Development tools modules
    devModules = [
      ./darwinModules/development/devTools.nix
      ./darwinModules/development/cloudTools.nix
      ./darwinModules/development/terminalTools.nix
    ];

    # Function to create Home Manager configurations
    mkHomeConfiguration = { system, hostName, user }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home_manager/${user}_${hostName}.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
          modulesPath = toString ./home_managerModules;
        };
      };


    # Function to create Darwin configurations
    mkDarwinSystem = { system, hostName, user, extraModules ? [] }: 
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { 
          inherit self inputs;
          inherit hostName user;
        };

        modules = darwinModules ++ devModules ++ extraModules ++ [
          ({ config, pkgs, ... }: {
            
            nix.enable = false;

            # system.primaryUser = user;

            # Host-specific files
            imports = [
              ./hosts/${hostName}/hardware-configuration.nix
              ./hosts/${hostName}/configuration.nix
              ./hosts/${hostName}/darwin-configuration.nix
              ./hosts/${hostName}/dev-tools.nix
              ./hosts/${hostName}/homeBrew.nix
            ];

            # Single host configuration file
            # imports = [ 
            #   (./hosts + "/${hostName}/default.nix") 
            # ];

            # Home Manager configuration
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./home_manager/${user}_${hostName}.nix;
              extraSpecialArgs = {
                inherit inputs;
                modulesPath = toString ./home_managerModules;
              };
            };

            # Consolidated Homebrew configuration
            nix-homebrew = {
              enable = (system == "x86_64-darwin"); # Only enable for Intel
              enableRosetta = (system == "aarch64-darwin");
              inherit user;
              autoMigrate = true;
              # mutableTaps = false;
              # taps = {
              #   "homebrew/cask" = inputs.nixpkgs.legacyPackages.${system}.homebrew-cask;
              # };
            };

             # Architecture-specific settings
            nixpkgs = {
              config.allowUnfree = true;
              hostPlatform = system;
              # overlays = [
              #   # Custom package overlay
              # ];
            };
          })
        ];
      };
  in {
    darwinConfigurations = {
      macbookPro = mkDarwinSystem {
        system = "x86_64-darwin";
        hostName = "macbookPro";
        user = "admin";
      };
      m4Pro = mkDarwinSystem {
        system = "aarch64-darwin";
        hostName = "m4Pro";
        user = "emilio";
      };
    };

    homeConfigurations = {
      "admin@macbookPro" = mkHomeConfiguration {
        system = "x86_64-darwin";
        hostName = "macbookPro";
        user = "admin";
      };
      "emilio@m4Pro" = mkHomeConfiguration {
        system = "aarch64-darwin";
        hostName = "m4Pro";
        user = "emilio";
      };
    };
  } // 
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Import devenv profiles with required arguments
      profiles = import ./devenv/profiles.nix {
        inherit (pkgs) lib;
        inherit pkgs;
      };

    in {
      devShells = {
        # default = devenv.lib.mkShell {
        #   inherit inputs pkgs;
        #   modules = [ profiles.djangoReactStack ];
        # };

        djangoReactStack = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [ profiles.djangoReactStack ];
        };

        # react = devenv.lib.mkShell {
        #   inherit inputs pkgs;
        #   modules = [ profiles.react ];
        # };
      };
    }
  );
}
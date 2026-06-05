{

  description = "Emilio Mac Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
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

  outputs = { self, nixpkgs, nix-darwin, home-manager, determinate, nix-homebrew, mac-app-util, devenv, flake-utils, gitignore, ... }@inputs:
  let

    # tmux 3.4 introduced an OSC 10/11 colour-query feature that, on tmux 3.5a,
    # leaks the terminal's reply into the pane at client attach — it shows up as
    # "10;rgb:.../11;rgb:..." before the prompt. This is an open upstream bug
    # (tmux/tmux#4634) with no fix and no option to disable the feature, so we
    # pin tmux to the last 3.3 release, which predates the feature entirely.
    tmuxPin = final: prev: {
      tmux = prev.tmux.overrideAttrs (_: rec {
        version = "3.3a";
        src = prev.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = version;
          sha256 = "sha256-SygHxTe7N4y7SdzKixPFQvqRRL57Fm8zWYHfTpW+yVY=";
        };
      });
    };

    # Development tools modules
    devModules = [
      ./darwinModules/development/devTools.nix
      ./darwinModules/development/cloudTools.nix
      ./darwinModules/development/terminalTools.nix
      ./darwinModules/development/customPackages.nix
    ];

    # Function to create Home Manager configurations
    mkHomeConfiguration = { system, hostName, user }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ tmuxPin ];
        };
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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ tmuxPin ];
        };
        specialArgs = {
          inherit self inputs;
          inherit hostName user;
        };

        modules = [
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          ./darwinModules/systemDefaults.nix
          ./darwinModules/desktopApps.nix
          ./darwinModules/fontPackage.nix
        ] ++ devModules ++ extraModules ++ [
          ({ config, pkgs, ... }: {

            system.primaryUser = user;

            # Host-specific files
            imports = [
              ./hosts/${hostName}/hardware-configuration.nix
              ./hosts/${hostName}/configuration.nix
              ./hosts/${hostName}/darwin-configuration.nix
              ./hosts/${hostName}/dev-tools.nix
              ./hosts/${hostName}/homeBrew.nix
            ];

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
            };

            # Architecture-specific settings
            nixpkgs = {
              config.allowUnfree = true;
              hostPlatform = system;
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
        djangoReactStack = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [ profiles.djangoReactStack ];
        };
      };
    }
  );
}
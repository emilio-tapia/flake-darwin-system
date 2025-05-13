# {
#   description = "Emilio Mac Nix-Darwin Flake";

#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#     nix-darwin.url = "github:LnL7/nix-darwin";
#     nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
#     home-manager.url = "github:nix-community/home-manager"; # Reference to home-manager for user-level configurations
#     home-manager.inputs.nixpkgs.follows = "nixpkgs";
#     nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
#     devenv.url = "github:cachix/devenv/latest";
#     flake-utils.url = "github:numtide/flake-utils";
#     gitignore.url = "github:hercules-ci/gitignore.nix";
#     mac-app-util.url = "github:hraban/mac-app-util";
#     lazyvim = {
#       url = "github:LazyVim/starter";
#       flake = false;
#     };
#   };

#   outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, devenv, flake-utils, gitignore, ... }@inputs:{
#     darwinConfigurations = {
#       # macbookPro configuration
#       macbookPro = nix-darwin.lib.darwinSystem {
#         system = "x86_64-darwin"; # Intel chip architecture
#         specialArgs = { 
#           inherit self inputs; 
#           # nvimModules = "./home_managerModules/lazyvim.nix";
#         };
#         modules = [
#           # Properly structure Home Manager integration
#           home-manager.darwinModules.home-manager
#           mac-app-util.darwinModules.default

#           # Host-specific configurations
#           ./hosts/macbookPro/hardware-configuration.nix
#           ./hosts/macbookPro/configuration.nix
#           ./hosts/macbookPro/darwin-configuration.nix

#           # Shared Darwin modules
#           ./darwinModules/systemDefaults.nix
#           ./darwinModules/cloudTools.nix
#           ./darwinModules/desktopApps.nix
#           ./darwinModules/development/globalDevTools.nix
#           ./darwinModules/development/intelDevTools.nix
#           ./darwinModules/terminalDefaults.nix
#           ./darwinModules/fontPackage.nix
#           ./darwinModules/homeBrew.nix
#           # ./darwinModules/vimTools.nix


#           # Home Manager configuration
#            {
#             home-manager = {
#               backupFileExtension = "backup";
#               useGlobalPkgs = true;
#               useUserPackages = true;
#               users.admin = import ./home_manager/admin_macbookPro.nix;
#               extraSpecialArgs = { 
#                 inherit inputs; 
#                 modulesPath = toString ./home_managerModules;
#               };
#             };
#           }


#           nix-homebrew.darwinModules.nix-homebrew {
#             nix-homebrew = {
#               enable = true;
#               # User owning the Homebrew prefix
#               user = "admin";
#             };
#           }
#         ];
#       };

#       # M4 Pro MacBook configuration
#       m4Pro = nix-darwin.lib.darwinSystem {
#         system = "aarch64-darwin"; # Apple Silicon architecture
#         specialArgs = { 
#           inherit self inputs;
#         };
#         modules = [

#           # ({ config, ... }: {                                                          # <--
#           #   homebrew.taps = builtins.attrNames config.nix-homebrew.taps;               # <--
#           # }) 

#           # Properly structure Home Manager integration
#           home-manager.darwinModules.home-manager
#           mac-app-util.darwinModules.default
#           nix-homebrew.darwinModules.nix-homebrew
          

#           # Host-specific configurations
#           ./hosts/m4Pro/hardware-configuration.nix
#           ./hosts/m4Pro/configuration.nix
#           ./hosts/m4Pro/darwin-configuration.nix

#           # Shared Darwin modules
#           ./darwinModules/systemDefaults.nix
#           ./darwinModules/cloudTools.nix
#           ./darwinModules/desktopApps.nix
#           ./darwinModules/development/globalDevTools.nix
#           # ./darwinModules/development/intelDevTools.nix
#           ./darwinModules/terminalDefaults.nix
#           ./darwinModules/fontPackage.nix
#           ./darwinModules/homeBrew.nix
#           # ./darwinModules/vimTools.nix


#           # Home Manager configuration
#           {
#             home-manager = {
#               backupFileExtension = "backup";
#               useGlobalPkgs = true;
#               useUserPackages = true;
#               users.emilio = import ./home_manager/emilio_m4Pro.nix;
#               extraSpecialArgs = { 
#                 inherit inputs;
#                 modulesPath = ./home_managerModules;
#               };
#             };
#           }

#            {
#             nix-homebrew = {
#               enable = false; #didn't work
#               enableRosetta = true; # Enable Rosetta for running x86 apps on ARM
#               user = "emilio";
#               # autoMigrate = true; # Automatically migrate existing Homebrew installations
#               # taps = {
#               #   # "conductorone/homebrew-cone" = cone-tap;
#               #   "homebrew/homebrew-core" = homebrew-core;
#               #   "homebrew/homebrew-cask" = homebrew-cask;
#               #   "nikitabobko/homebrew-tap" = nikitabobko-tap;
#               # };
#               # mutableTaps = false;
#             };
#           }
#         ];
#       };

#     };
#   };
# }


{

  description = "Emilio Mac Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager"; # Reference to home-manager for user-level configurations
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    devenv.url = "github:cachix/devenv/latest";
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
      ./darwinModules/systemDefaults.nix
      ./darwinModules/desktopApps.nix
      ./darwinModules/development/devTools.nix
      ./darwinModules/development/cloudTools.nix
      ./darwinModules/development/terminalTools.nix
      ./darwinModules/fontPackage.nix
      ./darwinModules/homeBrew.nix
    ];

    # Function to create Darwin configurations
    mkDarwinSystem = { system, hostName, user, extraModules ? [] }: 
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { 
          inherit self inputs;
          inherit hostName user;
        };
        modules = darwinModules ++ extraModules ++ [
          ({ config, pkgs, ... }: {
            # Host-specific files
            imports = [
              ./hosts/${hostName}/hardware-configuration.nix
              ./hosts/${hostName}/configuration.nix
              ./hosts/${hostName}/darwin-configuration.nix
              ./hosts/${hostName}/dev-tools.nix
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

            # Architecture-specific configurations
            nixpkgs.config.allowUnfree = true;
            nixpkgs.hostPlatform = system;
          })
        ];
      };
  in {
    darwinConfigurations = {
      macbookPro = mkDarwinSystem {
        system = "x86_64-darwin";
        hostName = "macbookPro";
        user = "admin";
        extraModules = [
          # ./darwinModules/development/intelDevTools.nix
          {
            nix-homebrew = {
              enable = true;
              user = "admin";
            };
          }
        ];
      };

      m4Pro = mkDarwinSystem {
        system = "aarch64-darwin";
        hostName = "m4Pro";
        user = "emilio";
        extraModules = [
          {
            nix-homebrew = {
              enable = false;
              enableRosetta = true;
              user = "emilio";
            };
          }
        ];
      };
    };
  };
}
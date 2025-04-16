{
  description = "Emilio Mac Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager"; # Reference to home-manager for user-level configurations
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
        # LazyVim starter template
    lazyvim = {
      url = "github:LazyVim/starter";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, ... }@inputs: {
    darwinConfigurations = {
      # macbookPro configuration
      macbookPro = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin"; # Intel chip architecture
        specialArgs = { 
          inherit self inputs; 
          nvimModules = "./home_managerModules/lazyvim.nix";
        };
        modules = [
          # Add Home Manager module


          # Add Mac App Util module
          mac-app-util.darwinModules.default
          ./hosts/macbookPro/hardware-configuration.nix
          ./hosts/macbookPro/configuration.nix
          ./hosts/macbookPro/darwin-configuration.nix
          ./darwinModules/systemDefaults.nix
          ./darwinModules/cloudTools.nix
          ./darwinModules/desktopApps.nix
          ./darwinModules/developmentTools.nix
          ./darwinModules/terminalDefaults.nix
          ./darwinModules/fontPackage.nix
          ./darwinModules/homeBrew.nix
          # ./darwinModules/vimTools.nix


          # Home Manager configuration (This is the correct one)
          home-manager.darwinModules.home-manager {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.admin = import ./hosts/macbookPro/home_manager/admin.nix;
              extraSpecialArgs = { 
                inherit inputs; 
                modulesPath = toString ./home_managerModules;
              };
            };
          }


          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              enable = true;
              # enableRosetta = true;
              # User owning the Homebrew prefix
              user = "admin";
            };
          }
        ];
      };

      # M4 Pro MacBook configuration
      m4Pro = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # Apple Silicon architecture
        specialArgs = { 
          inherit self inputs;
          modulesPath = toString ./home_managerModules;
        };
        modules = [
          mac-app-util.darwinModules.default
          ./hosts/m4Pro/hardware-configuration.nix
          ./hosts/m4Pro/configuration.nix
          ./hosts/m4Pro/darwin-configuration.nix
          ./darwinModules/systemDefaults.nix
          ./darwinModules/cloudTools.nix
          ./darwinModules/desktopApps.nix
          ./darwinModules/developmentTools.nix
          ./darwinModules/terminalDefaults.nix
          ./darwinModules/fontPackage.nix
          ./darwinModules/homeBrew.nix
          # ./darwinModules/vimTools.nix

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.admin = import ./hosts/m4Pro/home_manager/admin.nix;  # Needs matching structure
              extraSpecialArgs = { 
                inherit inputs;
                modulesPath = toString ./home_managerModules;
              };
            };
          }

          nix-homebrew.darwinModules.nix-homebrew {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # Enable Rosetta for running x86 apps on ARM
              user = "admin";
            };
          }
        ];
      };

    };
  };
}

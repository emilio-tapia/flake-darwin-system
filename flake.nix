{
  description = "Emilio Mac Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager"; # Reference to home-manager for user-level configurations
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util, ... }@inputs: {
    darwinConfigurations = {
      # macbookPro configuration
      macbookPro = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin"; # Intel chip architecture
        specialArgs = { inherit self inputs; };
        modules = [
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
          # ./darwinModules/module2.nix
          # ./darwinModules/subdir/module3.nix

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

      # macMini configuration
      # macMini = darwin.lib.darwinSystem {
      #   system = "x86_64-darwin";
      #   specialArgs = { inherit inputs; };
      #   modules = [
      #     ./hosts/macMini/configuration.nix
      #     ./hosts/macMini/hardware-configuration.nix
      #     ./darwinModules/module1.nix
      #     ./darwinModules/module2.nix
      #     ./darwinModules/subdir/module3.nix
      #   ];
      # };
    };
  };
}

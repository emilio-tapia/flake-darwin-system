{ self, config, pkgs, lib, ... }: 

{
  options = {
    darwinConfiguration.enable = lib.mkEnableOption "Enable darwinConfiguration-specific macOS configurations.";
  };

  config = lib.mkIf config.darwinConfiguration.enable {

    # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

    # Either this one, which blanket allows all unfree packages
    nixpkgs.config.allowUnfree = true;

    
    users.users.emilio = {
    home = "/Users/emiio";
    shell = "/bin/zsh";  # Or your preferred shell
  };

  };
}

{ self, config, pkgs, lib, ... }: 

{
  options = {
    darwinConfiguration.enable = lib.mkEnableOption "Enable darwinConfiguration-specific macOS configurations.";
  };

  config = lib.mkIf config.darwinConfiguration.enable {

    # Either this one, which blanket allows all unfree packages
    nixpkgs.config.allowUnfree = true;

  };
}

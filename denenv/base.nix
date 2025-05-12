# Common development environment settings
{ pkgs, ... }:
{
  packages = with pkgs; [
    # git
    pre-commit
    jq  #Lightweight and flexible command-line JSON processor
    # curl
  ];

  env = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  enterShell = ''
    echo "🚀 Development environment ready!"
  '';
}
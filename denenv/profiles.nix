# Profile combinations
{ ... }:
{
  fullstack = { pkgs, ... }: {
    imports = [
      ./frontend.nix
      ./backend.nix
    ];
    
    enterShell = ''
      echo "📝 Django (backend): cd core_backend"
      echo "🎨 React (frontend): cd core_frontend"
    '';
  };

  default = { pkgs, ... }: {
    imports = [ ./profiles.fullstack ];
  };
}
# Profile combinations
{ ... }:
{
  djangoReactStack = { pkgs, ... }: {
    imports = [
      ./djangoRest.nix
      ./react.nix
    ];
    
    enterShell = ''
      echo "📝 Django (backend): cd core_backend"
      echo "🎨 React (frontend): cd core_frontend"
    '';
  };

  default = { pkgs, ... }: {
    imports = [ ./profiles.djangoReactStack ];
  };
}
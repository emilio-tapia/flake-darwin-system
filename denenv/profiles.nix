# Profile combinations
{ ... }:
{
  djangoReactStack = { pkgs, ... }: {
    imports = [
      ./djangoRest/djangoRest.nix
      ./react/react.nix
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
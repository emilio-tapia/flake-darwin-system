# Vite/React frontend configuration
{ pkgs, ... }:
{
  imports = [ ../../base.nix ];

  packages = with pkgs; [
    # nodejs-18_x
    # pnpm
    # vite
  ];

  enterShell = ''
    if [ -d "core_frontend" ]; then
      echo "📦 Installing Node.js dependencies..."
      (cd core_frontend && pnpm install)
    else
      echo "⚠️  core_frontend directory not found"
    fi
  '';

  processes = {
    dev.run = "pnpm run dev";
    # dev.exec = "cd core_frontend && pnpm run dev";
  };

  scripts = {
    frontend-help = "echo '🎨 Frontend commands:\n  dev - Start development server'";
  };
}
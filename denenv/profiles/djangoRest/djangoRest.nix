# Django backend configuration
{ pkgs, ... }:
{
  imports = [ ../../base.nix ];

  packages = with pkgs; [
    # python311
    # pipenv
    # postgresql
    # redis
    pythonEnv
    pre-commit
  ];

  enterShell = ''
      echo "🚀 Starting Django development environment..."
              
      # check if core_backend directory is inside the current directory
      if [ ! -d "core_backend" ]; then
        echo "❌ Error: core_backend directory not found"
        return 1
      fi

      # Ensure the virtual environment exists
      if [ ! -d "core_backend/.venv" ]; then
        echo "🐍 Creating Python virtual environment..."
        ${pythonEnv}/bin/python -m venv core_backend/.venv
      fi

      # Activate the virtual environment
      source core_backend/.venv/bin/activate

      # Install Django if not installed
      if ! python -c "import django" 2>/dev/null; then
        echo "🎯 Installing Django..."
        pip install django
      fi

      # Create Django project if it doesn't exist
      if [ ! -f "core_backend/manage.py" ]; then
        echo "🎯 Creating Django project structure..."
        cd core_backend && django-admin startproject api_root . && cd ..
      fi

      # # Install Python dependencies from pyproject.toml if not already installed
      # if ! pip show core-backend >/dev/null 2>&1; then
      #   echo "📦 Installing Python dependencies..."
      #   pip install -e core_backend
      # fi

      echo "📦 Installing Python dependencies..."
        pip install -e core_backend
      
      echo ""
      echo "✅ Django backend ready!"
      echo ""
  '';

  processes = {
    # runserver.exec = "cd core_backend && python manage.py runserver";
    runserver.exec = "python manage.py runserver";
    # migrate.exec = "cd core_backend && python manage.py migrate";
  };

  scripts = {
    backend-help = "echo '📝 Backend commands:\n  runserver - Start Django server\n  migrate - Run migrations'";
  };
}
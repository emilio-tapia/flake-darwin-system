{ config, pkgs, lib, ... }: 

{
  options = {
    vimTools.enable = lib.mkEnableOption "Enable LazyVim, a Neovim configuration";
  };

  config = lib.mkIf config.vimTools.enable {
    # Install neovim
    environment.systemPackages = with pkgs; [
      # Neovim and dependencies
      neovim
      
      # Language servers and tools often used with LazyVim
      ripgrep
      fd
      
      # Optional but recommended tools
      lazygit
    ];

    # Create the LazyVim configuration  
      system.activationScripts.postActivation.text = ''
      # Get the actual logged-in user (works with sudo)
      USER="$(logname)"
      USER_HOME="/Users/$USER"
      NVIM_CONFIG="$USER_HOME/.config/nvim"

      echo "Detected user: $USER"
      echo "Config path: $NVIM_CONFIG"

      # Create directory as the real user
      sudo -u "$USER" mkdir -p "$NVIM_CONFIG"

      # Check for existing config
      if [ ! -f "$NVIM_CONFIG/init.lua" ]; then
        echo "Setting up LazyVim for $USER..."
        
        # Clone as the real user
        sudo -u "$USER" git clone https://github.com/LazyVim/starter "$NVIM_CONFIG" || {
          echo "Failed to clone LazyVim starter"
          exit 1
        }

        # Remove .git directory
        # sudo -u "$USER" rm -rf "$NVIM_CONFIG/.git"
        
        echo "LazyVim setup complete!"
      else
        echo "LazyVim configuration already exists for $USER, skipping setup."
      fi
    '';
  };
} 
{ config, pkgs, lib, ... }: 

{
  options = {
    lazyVim.enable = lib.mkEnableOption "Enable LazyVim, a Neovim configuration";
  };

  config = lib.mkIf config.lazyVim.enable {
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
      # Create nvim config directory if it doesn't exist
      mkdir -p ~/.config/nvim

      # Only clone if the directory is empty or doesn't exist
      if [ ! -f ~/.config/nvim/init.lua ]; then
        echo "Setting up LazyVim..."
        # Clear the directory first if it exists but is empty
        [ -d ~/.config/nvim ] && find ~/.config/nvim -mindepth 1 -maxdepth 1 | read -q || rm -rf ~/.config/nvim
        
        # Clone the LazyVim starter configuration
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        
        # Remove the .git directory to avoid conflicts
        rm -rf ~/.config/nvim/.git
        
        echo "LazyVim setup complete!"
      else
        echo "LazyVim configuration already exists, skipping setup."
      fi
    '';
  };
} 
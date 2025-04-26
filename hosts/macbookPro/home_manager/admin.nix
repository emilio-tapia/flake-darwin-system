{ inputs, config, pkgs, lib, nvimModules, ... }:

{
  # imports = [
  #   nvimModules
  # ];
  
  # Basic Home Manager configuration
  home = {
    username = "admin";
    stateVersion = "23.11";
      
    # Explicitly declare managed files
    file.".zshrc".enable = true;
  };
  
  programs = {
    zsh = {
        enable = true;
        oh-my-zsh.enable = true;
        oh-my-zsh.plugins = [ "git" "docker" ];
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = true;
        sync_address = "https://api.atuin.sh";
        style = "auto";
        workspaces = true;
      };
    };

      # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
    htop = {
      enable = true;
      settings.show_program_path = true;
    };

    neovim = {
      enable = true;

      # Install LazyVim dependencies
      extraPackages = with pkgs; [
        ripgrep  # Required for telescope
        fd       # Faster file finder
      ];

      # Bootstrap LazyVim configuration
      extraLuaConfig = ''
        -- Load LazyVim
        vim.g.mapleader = " "
        require("lazy").setup("plugins")
      '';
    };
  };

    # Deploy LazyVim starter files
  xdg.configFile."nvim" = {
    source = inputs.lazyvim;
    recursive = true;  # Copy entire directory structure
  };

  # xdg.configFile."nvim".source = ./nvim;  # Use local files
  
  # lazyvim.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment
    # hello
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/bashrc' in
    # # the Nix store and symlink it from your home directory.
    # ".bashrc".source = dotfiles/bashrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

}
{ inputs, config, pkgs, lib, nvimModules, ... }:

{

  # Basic Home Manager configuration
  home = {
    username = "emilio";
    homeDirectory = lib.mkDefault "/Users/emilio";  
    stateVersion = "23.11";

    packages = with pkgs; [
      atuin #shell history
      htop
      tmux
      alacritty
      yazi #terminal file manager 
      cheat
      fd
      fzf
      ripgrep
      bat # For file previews
      eza # For directory previews
      terminal-notifier
      zsh-autocomplete 
      zsh-powerlevel10k
    ];

    file.".p10k.zsh".source = ./config/p10k/.p10k.zsh; #Copies the file at that path into ~/.p10k.zsh
    # file.".p10k.zsh".text = builtins.readFile ./config/p10k/.p10k.zsh; #Reads the contents of ./p10k.zsh and writes them into ~/.p10k.zsh


      
    # Explicitly declare managed files
    # file.".zshrc".enable = true;
  };
  
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # dotDir = ".config/zsh"; # relative paths
      dotDir = "${config.xdg.configHome}/zsh";

      history = {
        size = 10000;
        ignoreDups = true;
        expireDuplicatesFirst = true;
      };

      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.zsh-autocomplete;  # Use the Nix package directly
          file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        }
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "z" ];
        custom = "$HOME/.config/zsh/omz-custom";
        extraConfig = ''
          zstyle ':completion:*' completer _expand _complete _ignored _approximate _expand_alias
          zstyle ':autocomplete:*' default-context curcontext
          zstyle ':autocomplete:*' min-input 0
          setopt HIST_FIND_NO_DUPS

          # Initialize completion system after adding paths
          autoload -Uz compinit && compinit   

          setopt autocd  # cd without writing 'cd'
          setopt globdots # show dotfiles in autocomplete list

          # p10k configuration
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
      };

      initContent = let
        fzfCmd = "${pkgs.fzf}/bin/fzf";
        fdCmd = "${pkgs.fd}/bin/fd";
      in ''
        # Widget creation must come first
        zle -N insert-unambiguous-or-complete
        zle -N menu-search
        zle -N recent-paths
        
        # Load manually fetched plugin
        # source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

        # Add to fpath for completion system
        # fpath+=(${pkgs.zsh-autocomplete}/share/zsh-autocomplete)

        # FZF configuration
        export FZF_DEFAULT_OPTS="--height 40% --reverse --border --preview-window=right:60%"
        export FZF_DEFAULT_COMMAND="${fdCmd} --type f --hidden --exclude .git"
        export FZF_ALT_C_COMMAND="${fdCmd} --type d --hidden --exclude .git"

        # File search widget (Ctrl+T)
        fzf-file-widget() {
          local selected
          selected=$(${fdCmd} --type f --hidden --exclude .git \
            | ${fzfCmd} --preview '${pkgs.bat}/bin/bat --color=always {}')
          [[ -n "$selected" ]] && LBUFFER+="''${(q)selected}"
          zle reset-prompt
        }
        zle -N fzf-file-widget
        bindkey '^T' fzf-file-widget
        # bindkey -M viins '^T' fzf-file-widget

        # Directory search widget (Ctrl+F)
        fzf-dir-widget() {
          local selected
          selected=$(${fdCmd} --type d --hidden --exclude .git \
            | ${fzfCmd} --preview '${pkgs.eza}/bin/eza -T --git --icons {}')
          [[ -n "$selected" ]] && LBUFFER+="''${(q)selected}"
          zle reset-prompt
        }
        zle -N fzf-dir-widget
        bindkey '^F' fzf-dir-widget
        

        # Atuin-FZF integration with error handling
        _atuin_search_fzf() {
          local selected
          if command -v atuin >/dev/null; then
            selected=$(${pkgs.atuin}/bin/atuin search --cmd-only --interactive)
            [[ -n "$selected" ]] && zle -U "$selected"
          else
            zle -U "$(fc -ln 1 | ${pkgs.fzf}/bin/fzf)"
          fi
          zle reset-prompt
        }
        zle -N _atuin_search_fzf
        bindkey '^r' _atuin_search_fzf

        # Menu selection binding
        # bindkey -M menuselect '^M' .accept-line # Makes pressing Enter (^M is Enter's control code) in the completion menu immediately execute the selected command

        # HOMEBREW 
        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      '';

    };


    atuin = {
      enable = true;
      # enableZshIntegration = false; # We're handling integration manually
      # enableBashIntegration = false; # Disable if not using Bash
      # enableFishIntegration = false; # Disable if not using Fish
      settings = {
        auto_sync = true;
        sync_address = "https://api.atuin.sh";
        style = "auto";
        workspaces = true;
        search_mode = "fuzzy";
        keymap_mode = "emacs";
        shell = "zsh";
        ctrl_r_override = false;  # Keep your binding
      };
    };

    fzf = {
      enable = true;
      # enableZshIntegration = false; # Handled manually
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";
      # fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";
    }; # https://github.com/junegunn/fzf

    htop = {
      enable = true;
      settings = {
        show_program_path = true;
        tree_view = true;
        highlight_base_name = true;
      };
    }; # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable

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

    starship = {
      enable = true;
        settings = {
          format = ''
            [░▒▓](cyan)[  $all ](bg:cyan fg:black) $directory $git_branch $git_status $cmd_duration $line_break $character
            '';

          add_newline = false;
          scan_timeout = 10;
          command_timeout = 2000;
          right_format = "$time";

          directory = {
            style = "bold cyan";
            truncation_length = 3;
            truncation_symbol = "…/";
            substitutions = {
              "Documents" = " ";
              "Downloads" = " ";
              "Music" = " ";
              "Pictures" = " ";
            };
          };

          git_branch = {
            symbol = " ";
            style = "bold purple";
            format = "[$symbol$branch(:$remote_branch)]($style) ";
          };

          git_status = {
            style = "bold red";
            conflicted = "🏳";
            ahead = "⇡\${count}";
            behind = "⇣\${count}";
            diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
            stashed = "★";
            modified = " \${count}";
            staged = " \${count}";
            renamed = " \${count}";
            deleted = " \${count}";
          };

          time = {
            disabled = false;
            time_format = "%R"; # 24h format
            style = "bold green";
            format = "[$time]($style) ";
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[✗](bold red)";
            vicmd_symbol = "[](bold blue)";
          };

          cmd_duration = {
            min_time = 5000;
            format = "took [$duration]($style) ";
            style = "bold yellow";
          };

          # Enable transient prompt for cleaner interface
          # transient = {
          #   enabled = true;
          #   format = "[$character](bold green) ";
          # };
        };
    };

    alacritty = {
      enable = true;
      settings = {
        # Performance & Core Settings
        window = {
          # decorations = "none"; # Remove title bar
          padding = { x = 5; y = 5; };
          dynamic_padding = true;
          startup_mode = "Windowed";
          title = "Terminal";
          opacity = 0.95;
        };

        scrolling = {
          history = 100000;
          multiplier = 3;
        };

        font = {
          normal = {
            family = "MesloLGS NF";
            style = "Regular";
          };
          bold = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Medium Italic";
          };
          size = 13.0;
          offset = {
            x = 0;
            y = 2;  # Creates slight "floating" effect
          };
        };

        colors = {
          primary = {
            background = "#0E1621";    # Deep ocean blue
            foreground = "#D1E5F9";    # Light sky blue
          };

          normal = {
            black =   "#002635";       # Abyssal dark
            red =     "#ff5e5e";       # Coral red
            green =   "#138A43";       # Sea foam green
            yellow =  "#ffe96c";       # Sunbeam yellow
            blue =    "#0370D6";       # Shallow water blue
            magenta = "#d18aff";       # Bioluminescent purple
            cyan =    "#0B9CB9";       # Tropical cyan
            white =   "#c7d0d7";       # Foam white
          };

          bright = {
            black =   "#003b5f";       # Deep sea
            red =     "#ff8484";       # Brighter coral
            green =   "#84ffc2";       # Bright sea foam
            yellow =  "#fff084";       # Bright sunbeam
            blue =    "#84d8ff";       # Bright shallow blue
            magenta = "#e8a5ff";       # Bright bioluminescent
            cyan =    "#84fff0";       # Bright tropical
            white =   "#e0e8f0";       # Bright foam
          };

          cursor = {
            cursor = "#025CB1";       # Matching blue
            text =   "#0a1a2f";        # Background color
          };

          selection = {
            text =   "#0a1a2f";        # Background color
            background = "#4C86A3";  # 
          };
        };

        cursor = {
          style = {
            shape = "Block";
            blinking = "On";
          };
          unfocused_hollow = true;
          blink_interval = 750;
          blink_timeout = 3;
        };

        mouse = {
          hide_when_typing = true;
        };

        terminal.shell = {
          program = "${pkgs.zsh}/bin/zsh";
        };

        # Platform-specific overrides (macOS)
        env.TERM = "xterm-256color";
      };
    };
  };

    # Deploy LazyVim starter files
  xdg.configFile."nvim" = {
    source = inputs.lazyvim;
    recursive = true;  # Copy entire directory structure
  };

  # xdg.configFile."nvim".source = ./nvim;  # Use local files

  # The home.packages option allows you to install Nix packages into your
  # environment.
  # home.packages = with pkgs; [
  #   # # Adds the 'hello' command to your environment
  #   # hello
  #   # # It is sometimes useful to fine-tune packages, for example, by applying
  #   # # overrides. You can do that directly here, just don't forget the
  #   # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  #   # # fonts?
  #   # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  # ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  
  # home.file = {
    # # Building this configuration will create a copy of 'dotfiles/bashrc' in
    # # the Nix store and symlink it from your home directory.
    # ".bashrc".source = dotfiles/bashrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    
  # };

  # You can also manage environment variables but you will have to manually
  # source
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

}
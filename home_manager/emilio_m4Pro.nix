{ inputs, config, pkgs, lib, options, ... }:

{

  # Basic Home Manager configuration
  home = {
    username = "emilio";
    homeDirectory = lib.mkDefault "/Users/emilio";  
    stateVersion = "23.11";

    packages = with pkgs; [
      atuin #shell history
      htop
      btop #htop
      alacritty
      yazi #terminal file manager 
      cheat
      fd #alternative to find
      fzf
      ripgrep #extends speed of grep
      bat # For file previews
      eza #Modern, maintained replacement for ls
      terminal-notifier
      zsh-autocomplete 
      zsh-powerlevel10k
      zsh-nix-shell
      jq #command-line JSON processor
      jqp #TUI playground to experiment with jq
      pgcli #Command-line interface for PostgreSQL
      # powerline-go #prompt for Bash, ZSH and Fish
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
      dotDir = ".config/zsh"; # relative paths
      # dotDir = "${config.xdg.configHome}/zsh";

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
      in lib.mkMerge [
        # Auto-start tmux only in Alacritty / WezTerm, before the rest of init.
        # Skip if not interactive or already inside tmux (avoids infinite re-exec,
        # since ALACRITTY_*/TERM_PROGRAM stay set in the tmux child shell).
        (lib.mkBefore ''
          if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && \
             { [[ -n "$ALACRITTY_WINDOW_ID" ]] || [[ "$TERM_PROGRAM" == "WezTerm" ]]; }; then
            # Reuse the first detached (unattached) session so windows don't pile
            # up as orphans; create a fresh session only when none are free.
            session=$(${pkgs.tmux}/bin/tmux list-sessions -F '#{session_attached} #{session_name}' 2>/dev/null \
                      | ${pkgs.gawk}/bin/awk '$1 == "0" { print $2; exit }')
            if [[ -n "$session" ]]; then
              exec ${pkgs.tmux}/bin/tmux attach-session -t "$session"
            else
              exec ${pkgs.tmux}/bin/tmux new-session
            fi
          fi
        '')
        ''
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


        # modifies the PATH environment variable, which tells your shell where to look for executable programs
        export PATH="$HOME/.local/bin:$PATH"
        ''
      ];

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

    btop = {
      enable = true;
      settings = {
        color_theme = "Default";
        theme_background = true;
        truecolor = true;
        vim_keys = false;
        presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
        rounded_corners = true;
        proc_sorting = "cpu lazy";
      };
    }; # https://github.com/aristocratos/btop#configurability

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
      enable = false;
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

    wezterm = {
      enable = true;
      # WezTerm is configured in Lua; this mirrors the Alacritty setup above.
      extraConfig = ''
        -- `local wezterm = require 'wezterm'` is injected by the Home Manager module.
        local config = wezterm.config_builder()

        -- Font
        config.font = wezterm.font_with_fallback {
          'MesloLGS NF',
          'FiraCode Nerd Font Mono',
        }
        config.font_size = 13.0

        -- Window
        config.window_background_opacity = 0.95
        config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
        config.window_decorations = 'TITLE | RESIZE'
        config.hide_tab_bar_if_only_one_tab = true
        config.scrollback_lines = 100000

        -- Cursor
        config.default_cursor_style = 'BlinkingBlock'
        config.cursor_blink_rate = 750
        config.hide_mouse_cursor_when_typing = true

        -- Shell
        config.default_prog = { '${pkgs.zsh}/bin/zsh' }

        -- Ocean color palette (matches Alacritty)
        config.colors = {
          foreground = '#D1E5F9',
          background = '#0E1621',
          cursor_bg = '#025CB1',
          cursor_fg = '#0a1a2f',
          cursor_border = '#025CB1',
          selection_bg = '#4C86A3',
          selection_fg = '#0a1a2f',
          ansi = {
            '#002635', -- black
            '#ff5e5e', -- red
            '#138A43', -- green
            '#ffe96c', -- yellow
            '#0370D6', -- blue
            '#d18aff', -- magenta
            '#0B9CB9', -- cyan
            '#c7d0d7', -- white
          },
          brights = {
            '#003b5f', -- bright black
            '#ff8484', -- bright red
            '#84ffc2', -- bright green
            '#fff084', -- bright yellow
            '#84d8ff', -- bright blue
            '#e8a5ff', -- bright magenta
            '#84fff0', -- bright cyan
            '#e0e8f0', -- bright white
          },
        }

        return config
      '';
    };

    tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 5000;
      keyMode = "vi";
      # shortcut = "b";  # Use as prefix Ctrl-b
      baseIndex = 1;    # Start window numbering at 1
      # Mouse off so the terminal's native selection + Cmd+C work as usual
      # (tmux mouse mode hijacks selection into its own copy buffer). Scroll
      # uses the terminal's scrollback; copy-mode is keyboard-driven.
      mouse = false;
      extraConfig = ''
        # Enable true color support (default-terminal set via the `terminal` option above)
        set -ga terminal-overrides ",alacritty:RGB"
        set -ga terminal-overrides ",alacritty:Tc"
        set -ga terminal-overrides ",xterm-wezterm:RGB"
        set -ga terminal-overrides ",xterm-wezterm:Tc"

        # Split panes using | and -
        bind * split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Reload config with prefix r
        bind r source-file ~/.config/tmux/tmux.conf\; display "Reloaded!"

        # Vim-like pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Resize panes with Alt-arrow
        bind -n M-Left resize-pane -L 5
        bind -n M-Right resize-pane -R 5
        bind -n M-Up resize-pane -U 5
        bind -n M-Down resize-pane -D 5

        # Status bar customization
        set -g status-interval 1
        set -g status-left " #[fg=white]#S #[fg=default]"
        set -g status-right "#[fg=white]%Y-%m-%d %H:%M "
        set -g status-style "fg=white,bg=#2d2d2d"
        set -g window-status-current-format "#[fg=cyan]#I:#W#F"
        set -g window-status-format "#[fg=white]#I:#W#F"

        # Fix Alt key passthrough delay
        set -s escape-time 0
        
        # Ensure proper keyboard input handling
        set -g xterm-keys on
        set -g focus-events on
      '';

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        continuum
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_tabs_enabled on
          '';
        }
        yank
      ];
    };

    eza = {
      enable = true;
    }; # https://github.com/nix-community/home-manager/blob/master/modules/programs/eza.nix

    ripgrep = {
      enable = true;
    }; # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/ripgrep.nix

    fd = {
      enable = true;
      ignores = [
          ".git/"
          "*.bak"
        ];
      hidden = true;
    }; # https://github.com/nix-community/home-manager/blob/master/modules/programs/fd.nix

    

    jq = {
      enable = true;
      colors = {
        null       = "1;30";
        false      = "0;31";
        true       = "0;32";
        numbers    = "0;36";
        strings    = "0;33";
        arrays     = "1;35";
        objects    = "1;37";
        objectKeys = "1;34";
      };
    };# https://github.com/nix-community/home-manager/blob/master/modules/programs/jq.nix
  }
  // lib.optionalAttrs (options.programs ? jqp) {
    jqp = {
      enable = true;
      settings = {
        theme = {
          name = "monokai";
          chromaStyleOverrides = {
            kc = "#009900 underline";
          };
        };
      };
    }; # https://github.com/nix-community/home-manager/blob/master/modules/programs/jqp.nix
  }
  // lib.optionalAttrs (options.programs ? pgcli) {
    pgcli = {
      enable = true;
      settings = {
          main = {
            smart_completion = true;
            destructive_warning = true;
            table_format = "psql";
            vi = false;
            keyring = true;
          };
          # "named queries".simple = "select * from abc where a is not Null";
        };
    }; # https://github.com/nix-community/home-manager/blob/master/modules/programs/pgcli.nix
    # https://www.pgcli.com/config
  };


  

    # Deploy LazyVim starter files
  xdg.configFile."nvim" = {
    source = inputs.lazyvim;
    recursive = true;  # Copy entire directory structure
  };

}
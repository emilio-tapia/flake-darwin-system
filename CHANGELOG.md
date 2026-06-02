# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [Unreleased]

## [1.3.1] — 2026-06-02

### Fixed
- El auto-arranque de tmux creaba una sesión nueva por cada ventana de Alacritty/WezTerm (`exec tmux new-session`), que quedaban como sesiones detached huérfanas y se acumulaban sin límite. Ahora reutiliza la primera sesión libre (detached) y solo crea una nueva cuando todas están en uso, en ambos hosts

## [1.3.0] — 2026-06-02

### Added
- `programs.wezterm` declarativo en Nix en m4Pro y macbookPro, con fuente (`MesloLGS NF`) y paleta oceánica espejo de la configuración de Alacritty
- Auto-arranque de tmux al abrir Alacritty o WezTerm, vía `programs.zsh.initContent` (detección por `ALACRITTY_WINDOW_ID`/`TERM_PROGRAM`, sesión nueva e independiente por ventana), en ambos hosts
- Override de true color de tmux para WezTerm (`xterm-wezterm:RGB`/`:Tc`) en ambos hosts

### Changed
- WezTerm migrado de cask de Homebrew a Nix (`programs.wezterm`) en m4Pro
- `programs.tmux.terminal` corregido a `tmux-256color` en ambos hosts, eliminando la contradicción con el `default-terminal` del `extraConfig`
- En macbookPro el shell de Alacritty vuelve a ser zsh plano; tmux ahora se inicia desde el `.zshrc` en lugar del hack `zsh -l -c "tmux new -A -s main"`

### Removed
- `tmux` duplicado en `home.packages` de emilio (ya lo provee `programs.tmux`)

## [1.2.0] — 2026-05-14

### Added
- Módulo `customPackages` para empaquetar herramientas Python/Go/npm desde GitHub (helper `mkPythonAppFromGitHub` + plantillas para `buildGoModule` / `buildNpmPackage`), habilitado en m4Pro y macbookPro

### Changed
- pnpm movido de nix packages a Homebrew brew en ambos hosts (para acceder a la serie 11.x, no disponible en nixpkgs-25.05)
- `homebrew.onActivation.autoUpdate` activado en m4Pro y macbookPro

### Removed
- vscode deshabilitado en `darwinModules/desktopApps.nix` (en desuso)

## [1.1.1] — 2026-03-28

### Added
- Wezterm cask en m4Pro

### Changed
- Opencode movido de nix packages a Homebrew brew
- Skill version-control actualizado con gestión de changelog y versionamiento

## [1.1.0] — 2026-03-26

### Added
- Homebrew brews verificados: llmfit, models, whosthere, mole, snitch, bookokrat, dnspyre, cronboard, gittype
- Casks habilitados en macbookPro: cursor, figma, losslesscut, handbrake-app
- Code review analysis y Claude skills

### Changed
- Inputs del flake unificados a nixpkgs 25.05, nix-darwin 25.05, home-manager release-25.05
- Integración de `determinate.darwinModules.default` en ambas configuraciones
- Usuario dinámico de PostgreSQL vía `specialArgs`
- Sincronización de brews entre m4Pro y macbookPro
- Corrección de nombres de taps en Homebrew
- Docker-desktop deshabilitado en macbookPro

### Fixed
- `zsh.dotDir` corregido a ruta relativa en home-manager
- Guardas `optionalAttrs` para pgcli/jqp por compatibilidad de versión
- Paquetes no disponibles en 25.05 comentados con explicación
- Homebrew configs corregidos en ambos hosts

## [1.0.0]

### Added
- Flake nix-darwin para dos hosts: m4Pro (aarch64) y macbookPro (x86_64)
- Home Manager integrado como módulo de nix-darwin
- Homebrew gestionado vía nix-homebrew
- devenv con perfiles de desarrollo
- Sistema de versionamiento inicializado

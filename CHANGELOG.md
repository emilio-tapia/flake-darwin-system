# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [Unreleased]

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

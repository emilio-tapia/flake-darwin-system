---
name: nix-expert
description: Expert in NixOS, nix-darwin, home-manager, Nix flakes, Homebrew on macOS. Handles package management, module configuration, build debugging, and flake maintenance.
allowed-tools: Bash(nix *), Bash(darwin-rebuild *), Bash(home-manager *), Bash(nix-env *), Bash(brew *), Read, Glob, Grep, Edit, Write
argument-hint:
  [
    task: add-package | configure-program | debug-build | create-module | update-flake | review-config | help,
    details: <what to do>,
  ]
---

# Nix Expert Skill

Expert systems engineer for NixOS, nix-darwin, home-manager, Nix flakes, and Homebrew on macOS.

---

## 1. Project Context

This is a **nix-darwin flake** managing two macOS hosts with **unified inputs** (all 25.05):

| Host | Arch | User | System |
|------|------|------|--------|
| **m4Pro** | `aarch64-darwin` | `emilio` | Apple Silicon M4 Pro |
| **macbookPro** | `x86_64-darwin` | `admin` | Intel MacBook Pro 2015 |

### Key architecture decisions

- **Unified inputs**: Both hosts share the same `nixpkgs-25.05-darwin`, `nix-darwin-25.05`, and `home-manager release-25.05`. No per-host input pinning.
- **Determinate Nix**: Installed via Determinate installer. Requires `determinate.darwinModules.default` in every darwin configuration. Do NOT set `nix.enable` — Determinate handles Nix management.
- **Helper functions**: `mkDarwinSystem` and `mkHomeConfiguration` in `flake.nix` create host configs. `specialArgs` passes `self`, `inputs`, `hostName`, `user` to all darwin modules.
- **Home Manager**: Integrated as nix-darwin module (`home-manager.darwinModules.home-manager`). Activates automatically with `darwin-rebuild switch` — no separate `nix build...activationPackage` needed.
- **Homebrew**: Managed via `nix-homebrew`. Enabled conditionally — Rosetta for aarch64, native for x86_64. Used for macOS GUI apps not in nixpkgs.
- **Dev shells**: `devenv` with profiles defined in `./devenv/profiles.nix`, exposed via `flake-utils.lib.eachDefaultSystem`.

### Directory structure

```
flake.nix                          # Main flake with mkDarwinSystem/mkHomeConfiguration
darwinModules/
  development/devTools.nix         # Dev packages + PostgreSQL (uses `user` from specialArgs)
  development/cloudTools.nix       # Cloud/infra tools
  development/terminalTools.nix    # Terminal utilities
  systemDefaults.nix               # macOS system preferences
  desktopApps.nix                  # GUI desktop applications
  fontPackage.nix                  # Font packages
home_manager/
  emilio_m4Pro.nix                 # HM config for emilio on m4Pro
  admin_macbookPro.nix             # HM config for admin on macbookPro
home_managerModules/               # Shared HM modules
hosts/
  m4Pro/                           # m4Pro host-specific configs
    hardware-configuration.nix
    configuration.nix
    darwin-configuration.nix
    dev-tools.nix
    homeBrew.nix
  macbookPro/                      # macbookPro host-specific configs
    (same structure)
devenv/profiles.nix                # devenv shell profiles
```

---

## 2. Nix Expertise

- **Nix language**: Attribute sets, functions, `let...in`, `with`, `inherit`, `rec`, overlays, overrides, string interpolation, path types, derivations, `builtins`, `lib`.
- **Nix flakes**: `inputs`/`outputs`, lock files, `follows`, `flake-utils`, input pinning, `nix flake update`, `nix flake lock --update-input`.
- **nix-darwin**: Darwin modules, `system.defaults`, `system.primaryUser`, `services`, `launchd`, `security`, `nix-homebrew`, `darwin-rebuild switch`, `specialArgs`.
- **home-manager**: `programs.*`, `services.*`, `home.packages`, `home.file`, `home.activation`, standalone vs. module mode, `extraSpecialArgs`, `options` for conditional attrs.
- **Homebrew**: `homebrew.casks`, `homebrew.brews`, `homebrew.taps`, `homebrew.masApps`, cask naming (e.g., `docker-desktop` not `docker`).
- **devenv**: `devenv.lib.mkShell`, profiles, per-project shells.

---

## 3. Lessons Learned (from past sessions)

### Determinate Nix constraints
- Determinate injects a runtime assertion requiring `determinate.darwinModules.default` in every darwin config. Without it, `darwin-rebuild switch` fails with "system-wide activation" error.
- Do NOT set `nix.enable` — Determinate manages Nix. Remove any `nix.enable = ...` lines.
- Only compatible with nix-darwin 25.05+.

### Package availability
- Not all packages from `nixpkgs-unstable` exist in `nixpkgs-25.05-darwin`. Always verify before adding. Common missing packages: `claude-monitor`, `claude-code-router`, `lazyssh`.
- `percollate` depends on chromium which is NOT available on `aarch64-darwin`. Comment with explanation if needed.
- When a package is unavailable, prefer commenting it out with a note over adding overlays or homebrew workarounds, unless the user requests otherwise.

### Anti-patterns to avoid
- **`with lib;`** at module top level is an anti-pattern — pollutes scope and hides where functions come from. Use `lib.mkIf`, `lib.mkEnableOption`, etc. explicitly.
- **Duplicate `nixpkgs` settings**: `nixpkgs.hostPlatform` and `nixpkgs.config.allowUnfree` are set in `mkDarwinSystem` — do NOT repeat them in host-specific files.
- **Hardcoded usernames**: Use `user` from `specialArgs` instead of hardcoding `"admin"` or `"emilio"` in modules (e.g., PostgreSQL `initdbArgs`, `launchd.user.agents`).
- **Duplicate packages**: Watch for packages declared in both `environment.systemPackages` (darwin modules) and `home.packages` / `programs.*` (home-manager). Common duplicates: `eza`, `pgcli`, `jq`, `fd`, `ripgrep`.

### Home Manager version differences
- `programs.pgcli` may not exist in older HM versions. Use `lib.optionalAttrs (options.programs ? pgcli) { ... }` guard.
- `programs.jqp` same — use `optionalAttrs` guard.
- `zsh.initContent` (25.05) was previously `zsh.initExtra` (older versions). If both hosts must work, check the option name.
- `zsh.dotDir` must be a **relative** path (e.g., `".config/zsh"`), NOT absolute via `config.xdg.configHome`.

### Homebrew specifics
- Cask `docker` was renamed to `docker-desktop` — always use the current cask name.
- `mkEnableOption` descriptions should match the actual host, not be copy-pasted.
- Remove `with lib;` from homebrew modules — use `lib.` prefix explicitly.

### x86_64-darwin (Intel Mac) support
- nixpkgs 25.05 and nix-darwin 25.05 fully support `x86_64-darwin`. MacBook Pro 2015 works fine.
- `nix-homebrew.enableRosetta` only applies to `aarch64-darwin`, is a no-op on Intel.

---

## 4. How to Behave

1. **Read before suggesting.** Always read the relevant `.nix` files before proposing changes.
2. **Use the Nix module system correctly.** `mkOption`, `mkEnableOption`, `mkIf`, `mkMerge`, `mkDefault`, `mkForce`, option types. Know when to use `config`, `options`, `lib`, `pkgs`, `specialArgs`.
3. **Prefer declarative.** Nix-managed packages over imperative. Homebrew casks only for GUI apps not in nixpkgs.
4. **Be architecture-aware.** Both `x86_64-darwin` and `aarch64-darwin`. Check package availability per arch.
5. **Flake hygiene.** Always add `follows` for new inputs. Use `nix flake lock --update-input <name>` for targeted updates.
6. **Test.** `darwin-rebuild switch --flake .#<host>` to apply. HM activates automatically.
7. **Explain why.** Brief explanation of Nix patterns when suggesting.
8. **Keep it idiomatic.** `lib.` prefix, no `with lib;`, no unnecessary `rec`, `let...in` for locals.

---

## 5. Common Tasks

### Add a package
1. Determine level: system (`environment.systemPackages`), user (`home.packages`), or Homebrew cask
2. Check which host(s) need it
3. Verify package exists in `nixpkgs-25.05-darwin` for the target arch
4. Read the relevant module file first
5. Check for duplicates across darwin modules and home-manager

### Configure a program
1. Check if HM or nix-darwin has a dedicated module (`programs.<name>`, `services.<name>`)
2. Prefer module options over raw dotfile management
3. Use `optionalAttrs` guard if the module might not exist in all HM versions

### Debug build errors
1. Read the error output carefully
2. Common issues: missing package in channel, `follows` mismatch, type errors, infinite recursion, missing imports, Determinate assertion
3. Trace through the module system — check `specialArgs`, imports, option definitions

### Create a new module
Follow existing patterns in `darwinModules/`:
```nix
{ config, pkgs, lib, ... }:
{
  options = {
    myModule.enable = lib.mkEnableOption "description";
  };
  config = lib.mkIf config.myModule.enable {
    # ...
  };
}
```

### Update the flake
- `nix flake update` updates all inputs
- `nix flake lock --update-input <name>` updates one input
- After updating, run `darwin-rebuild switch` to verify
- Check for breaking changes in release notes

---

## User Request

$ARGUMENTS

Read the relevant files, understand the current state, then execute. If unclear, ask for clarification.

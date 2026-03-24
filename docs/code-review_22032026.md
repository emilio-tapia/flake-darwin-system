# Analisis de Codigo - nix-darwin Configuration

**Fecha:** 2026-03-21
**Alcance:** Revision completa del repositorio nix-darwin

---

## Plan de Cambios

A continuacion se detallan todos los cambios propuestos, organizados por prioridad. Cada cambio incluye el **objetivo**, los **archivos afectados** y la **accion concreta**.

---

### CAMBIO 1 — [BUG CRITICO] PostgreSQL hardcodea usuario `admin`

**Objetivo:** El servicio PostgreSQL (directorio de datos, initdb, launchd) usa `"admin"` hardcodeado. En el host m4Pro el usuario es `"emilio"`, por lo que el servicio no puede funcionar: el `chown` falla, initdb crea un superusuario incorrecto, y launchd intenta correr como un usuario inexistente.

**Archivo:** `darwinModules/development/devTools.nix`

**Accion:** El modulo ya recibe `user` via `specialArgs` del flake (linea 70 de `flake.nix`). Voy a:
1. Agregar `user` a los argumentos del modulo: `{ config, pkgs, lib, user, ... }:`
2. Reemplazar las 3 ocurrencias de `admin` por `${user}`:
   - Linea 66: `chown -R admin:staff` -> `chown -R ${user}:staff`
   - Linea 75: `"-U admin"` -> `"-U ${user}"`
   - Linea 84: `UserName = "admin"` -> `UserName = user`

---

### CAMBIO 2 — [BUG CRITICO] `nixpkgs.hostPlatform` duplicado en macbookPro

**Objetivo:** `nixpkgs.hostPlatform` se define en dos sitios para macbookPro: en `hosts/macbookPro/darwin-configuration.nix:15` y en `flake.nix:135`. Nix rechaza definiciones multiples de la misma opcion cuando los valores vienen de modulos distintos. El flake ya lo maneja correctamente para ambos hosts, asi que la definicion en el host es redundante.

**Archivo:** `hosts/macbookPro/darwin-configuration.nix`

**Accion:** Eliminar la linea 15: `nixpkgs.hostPlatform = "x86_64-darwin";`

---

### CAMBIO 3 — [BUG MEDIO] `nixpkgs.config.allowUnfree` redundante

**Objetivo:** `allowUnfree = true` se define en 3 lugares: `flake.nix:66` (mkDarwinSystem pkgs import), `flake.nix:134` (nixpkgs.config), y en ambos `darwin-configuration.nix`. Las definiciones en los darwin-configuration son innecesarias porque el flake ya lo maneja.

**Archivos:**
- `hosts/m4Pro/darwin-configuration.nix`
- `hosts/macbookPro/darwin-configuration.nix`

**Accion:** Eliminar `nixpkgs.config.allowUnfree = true;` de ambos archivos.

---

### CAMBIO 4 — [BUG MEDIO] Cask `sourcetree` duplicado

**Objetivo:** `"sourcetree"` aparece en las lineas 42 y 48 de `hosts/m4Pro/homeBrew.nix`. Homebrew genera warnings al intentar instalar un cask que ya esta instalado.

**Archivo:** `hosts/m4Pro/homeBrew.nix`

**Accion:** Eliminar la segunda ocurrencia de `"sourcetree"` (linea 48).

---

### CAMBIO 5 — [BUG MEDIO] Descripcion incorrecta en mkEnableOption de macbookPro

**Objetivo:** La descripcion del option `intelHomeBrew.enable` dice "M4 Pro" pero el archivo es la config de Homebrew para el MacBook Pro Intel. Esto confunde al leer el codigo.

**Archivo:** `hosts/macbookPro/homeBrew.nix`

**Accion:** Cambiar la descripcion de:
```
"Enable homebrew M4 Pro default configurations."
```
a:
```
"Enable homebrew Intel MacBook Pro default configurations."
```

---

### CAMBIO 6 — [BUG BAJO] Parametro `option` (singular) en admin_macbookPro.nix

**Objetivo:** El archivo recibe `option` como argumento pero el nombre correcto en Home Manager es `options` (plural). Actualmente no causa error porque no se usa y el `...` lo absorbe, pero si en algun momento se necesita acceder a `options` (como ya se hace en `emilio_m4Pro.nix` para los `optionalAttrs`), no estara disponible con el nombre correcto.

**Archivo:** `home_manager/admin_macbookPro.nix`

**Accion:** Cambiar `option` por `options` en la linea 1.

---

### CAMBIO 7 — [DUPLICADOS] Eliminar paquetes repetidos en home.packages

**Objetivo:** Varios paquetes se instalan tanto en `home.packages` como via `programs.<name>.enable = true`. Cuando usas `programs.eza.enable = true`, Home Manager ya instala el paquete `eza` automaticamente. Tenerlo tambien en `home.packages` es redundante y puede causar conflictos de PATH o builds mas lentos.

**Archivos:** `home_manager/emilio_m4Pro.nix` y `home_manager/admin_macbookPro.nix`

**Accion en ambos archivos — eliminar de `home.packages`:**
- `eza` — ya esta en `programs.eza.enable = true`
- `fd` — ya esta en `programs.fd.enable = true`
- `ripgrep` — ya esta en `programs.ripgrep.enable = true`
- `jq` — ya esta en `programs.jq.enable = true`
- `pgcli` — ya esta en `programs.pgcli.enable = true`
- `jqp` — ya esta en `programs.jqp.enable = true`

Ademas, eliminar `pgcli` de `darwinModules/development/devTools.nix:17` (paquete de sistema) porque ya se gestiona via `programs.pgcli` en home-manager.

Y eliminar `eza` de `darwinModules/development/terminalTools.nix:51` porque ya se gestiona via `programs.eza` en home-manager.

**Nota:** Los `ripgrep` y `fd` en `neovim.extraPackages` se mantienen. Estos se inyectan solo en el PATH de neovim y son necesarios para telescope/grep dentro del editor.

---

### CAMBIO 8 — [INCONSISTENCIA] Plugin zsh-nix-shell no cargado en emilio_m4Pro

**Objetivo:** `zsh-nix-shell` esta en `home.packages` de `emilio_m4Pro.nix` (linea 27) pero **no** esta configurado como plugin de zsh (a diferencia de `admin_macbookPro.nix:68-72`). Esto significa que el paquete se descarga pero nunca se activa. El plugin permite que nix-shell use zsh en lugar de bash.

**Archivo:** `home_manager/emilio_m4Pro.nix`

**Accion:** Agregar el plugin en la seccion `zsh.plugins` (despues del plugin powerlevel10k, linea 67):
```nix
{
  name = "zsh-nix-shell";
  src = pkgs.zsh-nix-shell;
  file = "share/zsh-nix-shell/zsh-nix-shell.plugin.zsh";
}
```

---

### CAMBIO 9 — [INCONSISTENCIA] `dotDir` usa ruta absoluta en admin_macbookPro

**Objetivo:** En `admin_macbookPro.nix:49`, `dotDir` usa `"${config.xdg.configHome}/zsh"` que se expande a una ruta absoluta como `/Users/admin/.config/zsh`. La opcion `dotDir` de Home Manager espera una **ruta relativa al home** del usuario. Usar una ruta absoluta puede causar que Home Manager genere rutas como `/Users/admin//Users/admin/.config/zsh`. En `emilio_m4Pro.nix:48` se usa correctamente `".config/zsh"`.

**Archivo:** `home_manager/admin_macbookPro.nix`

**Accion:** Cambiar linea 49 de:
```nix
dotDir = "${config.xdg.configHome}/zsh";
```
a:
```nix
dotDir = ".config/zsh";
```

---

### CAMBIO 10 — [LIMPIEZA] Eliminar codigo muerto y templates

**Objetivo:** Reducir ruido visual en los archivos mas grandes. Hay ~60 lineas de template comments de Home Manager que no aportan valor (la documentacion oficial es mejor referencia), bloques `home.sessionVariables` vacios, y el argumento `nvimModules` que no se usa en ningun archivo.

**Archivos:** `home_manager/emilio_m4Pro.nix` y `home_manager/admin_macbookPro.nix`

**Accion en ambos archivos:**
1. Eliminar `nvimModules` de los argumentos del modulo (linea 1)
2. Eliminar el bloque de template comments (lineas ~539-565 en emilio, ~554-580 en admin)
3. Eliminar `home.sessionVariables` vacio (con solo un comentario dentro)

---

### CAMBIO 11 — [LIMPIEZA] Eliminar `with lib;` innecesario en homebrew configs

**Objetivo:** Ambos archivos de homebrew (`hosts/*/homeBrew.nix`) usan `with lib;` en el nivel superior pero solo referencian `lib.mkEnableOption` y `lib.mkIf`, que ya estan disponibles porque `lib` esta en los argumentos. El `with lib;` en nivel superior es un anti-patron en Nix porque contamina el scope y puede ocultar shadowing de nombres.

**Archivos:** `hosts/m4Pro/homeBrew.nix` y `hosts/macbookPro/homeBrew.nix`

**Accion:** Eliminar la linea `with lib;` de ambos archivos. Los usos de `lib.mkEnableOption` y `lib.mkIf` ya usan el prefijo `lib.`, por lo que no se necesita el `with`.

---

## Cambios NO incluidos (requieren decision del usuario)

Los siguientes puntos se identificaron pero **no se implementaran** porque son decisiones de arquitectura que necesitan tu input:

### A. Extraer modulo comun de home-manager
Los dos archivos `emilio_m4Pro.nix` y `admin_macbookPro.nix` comparten ~90% del codigo. Crear un `home_managerModules/common.nix` eliminaria ~400 lineas duplicadas, pero es un refactor grande que cambia la estructura del proyecto.

### B. PostgreSQL como modulo separado
Mover PostgreSQL de `devTools.nix` a su propio modulo (`darwinModules/development/postgresql.nix`) con opciones configurables (user, dataDir, auth method). Haria la config mas limpia pero agrega un archivo mas.

### C. Renombrar `denenv/` a `devenv/`
El directorio se llama `denenv` pero la herramienta es `devenv`. Requiere actualizar la referencia en `flake.nix:188`.

### D. Logs de PostgreSQL en `/tmp`
Los logs en `/tmp/postgres.log` son accesibles por cualquier usuario y se pierden al reiniciar. Se podrian mover a `~/Library/Logs/postgresql/`.

### E. Homebrew shellenv faltante en macbookPro
`admin_macbookPro.nix` no tiene el equivalente Intel de `eval "$(/usr/local/bin/brew shellenv)"`. Si Homebrew se usa en ese host, los comandos brew no estarian en PATH.

### F. Configuracion de Starship deshabilitada
Ambos home-manager configs tienen ~70 lineas de configuracion de Starship con `enable = false`. Se podria eliminar o mover a un archivo separado si se planea usar en el futuro.

---

## Resumen de impacto

| # | Cambio | Archivos | Riesgo |
|---|---|---|---|
| 1 | PostgreSQL dinamico con `user` | devTools.nix | Medio — cambia comportamiento del servicio |
| 2 | Eliminar hostPlatform duplicado | macbookPro/darwin-configuration.nix | Bajo |
| 3 | Eliminar allowUnfree redundante | ambos darwin-configuration.nix | Bajo |
| 4 | Eliminar sourcetree duplicado | m4Pro/homeBrew.nix | Bajo |
| 5 | Corregir descripcion mkEnableOption | macbookPro/homeBrew.nix | Ninguno |
| 6 | Corregir `option` -> `options` | admin_macbookPro.nix | Bajo |
| 7 | Eliminar paquetes duplicados | ambos home_manager + devTools + terminalTools | Bajo |
| 8 | Activar plugin zsh-nix-shell | emilio_m4Pro.nix | Bajo |
| 9 | Corregir dotDir absoluto | admin_macbookPro.nix | Bajo |
| 10 | Eliminar codigo muerto | ambos home_manager | Ninguno |
| 11 | Eliminar `with lib;` | ambos homeBrew.nix | Ninguno |

**Despues de aplicar los cambios, ejecutar:** `sudo darwin-rebuild switch --flake .#m4Pro` para verificar.

---

## Hallazgos del Build (2026-03-22)

Se ejecuto `sudo darwin-rebuild switch --flake ~/.config/nix-darwin#m4Pro` exitosamente.

### Paquetes comentados (no disponibles en nixpkgs-25.05-darwin)

| Paquete | Archivo | Razon |
|---|---|---|
| `claude-monitor` | `devTools.nix` | Solo en nixpkgs-unstable |
| `claude-code-router` | `devTools.nix` | Solo en nixpkgs-unstable |
| `lazyssh` | `terminalTools.nix` | Solo en nixpkgs-unstable |
| `percollate` | `terminalTools.nix` | Depende de chromium, no disponible en aarch64-darwin |

### Warnings de Homebrew

- `docker` fue renombrado a `docker-desktop` — cambiar en `hosts/m4Pro/homeBrew.nix` y `hosts/macbookPro/homeBrew.nix`
- `sourcetree` aparece duplicado en m4Pro (ya documentado en CAMBIO 4)

### CAMBIO 12 — [BUG BAJO] Cask `docker` renombrado a `docker-desktop`

**Objetivo:** Homebrew renombro el cask `docker` a `docker-desktop`. El cask antiguo sigue funcionando con un warning pero podria dejar de funcionar en futuras versiones de Homebrew.

**Archivos:** `hosts/m4Pro/homeBrew.nix` y `hosts/macbookPro/homeBrew.nix`

**Accion:** Reemplazar `"docker"` por `"docker-desktop"` en ambos archivos.

### Home Manager integrado

Confirmado: Home Manager se activa automaticamente via `darwin-rebuild switch`. El comando separado `nix build ...homeConfigurations...activationPackage && result/activate` **no es necesario** en el flujo normal. El bloque `homeConfigurations` en `flake.nix` sirve como respaldo standalone.

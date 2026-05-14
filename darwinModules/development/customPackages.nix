{ config, pkgs, lib, ... }:

let
  pip = pkgs.python313Packages;

  mkPythonAppFromGitHub =
    { name
    , version
    , owner
    , repo ? name
    , rev ? "v${version}"
    , hash
    , buildSystem ? [ pip.setuptools ]
    , deps ? []
    }:
    pip.buildPythonApplication {
      pname = name;
      inherit version;
      pyproject = true;
      src = pkgs.fetchFromGitHub { inherit owner repo rev hash; };
      build-system = buildSystem;
      dependencies = deps;
    };
in
{
  options = {
    customPackages.enable =
      lib.mkEnableOption "Paquetes custom no disponibles en nixpkgs/homebrew (Python/Go/npm desde GitHub)";
  };

  config = lib.mkIf config.customPackages.enable {
    environment.systemPackages = [

      # ---------- PYTHON ----------

      (pip.toPythonApplication pip.dirsearch)

      # dhv: bloqueado porque `textual-fspicker` no está en nixpkgs 25.05.
      # Para habilitarlo: empaquetar textual-fspicker como subderivación
      # (buildPythonPackage) o migrar a uv2nix.
      # (mkPythonAppFromGitHub {
      #   name = "dhv";
      #   version = "0.5.0";
      #   owner = "davep";
      #   hash = lib.fakeHash;
      #   buildSystem = [ pip.uv-build ];
      #   deps = with pip; [
      #     textual
      #     textual-fspicker
      #     xdg-base-dirs
      #   ];
      # })

      # ---------- GO (plantilla) ----------
      # (pkgs.buildGoModule rec {
      #   pname = "tinifier";
      #   version = "5.0.0";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "tarampampam";
      #     repo  = "tinifier";
      #     rev   = "v${version}";
      #     hash  = lib.fakeHash;
      #   };
      #   vendorHash = lib.fakeHash;
      # })

      # ---------- NPM (plantilla) ----------
      # (pkgs.buildNpmPackage rec {
      #   pname = "<nombre>";
      #   version = "<x.y.z>";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "<owner>";
      #     repo  = "<repo>";
      #     rev   = "v${version}";
      #     hash  = lib.fakeHash;
      #   };
      #   npmDepsHash = lib.fakeHash;
      # })

    ];
  };
}

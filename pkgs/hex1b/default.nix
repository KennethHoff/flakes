# Per-tool module. The root flake auto-discovers this directory and folds the
# returned attrset into the flake outputs. Contract (all keys optional):
#   { packages, apps, checks, devShellPackages }
{
  inputs,
  system,
  self,
  lib,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  versions = import ./versions.nix;

  hex1b = pkgs.callPackage ./package.nix {
    inherit (versions) version srcHash;
    nugetDeps = ./deps.json;
  };
in
{
  packages = {
    hex1b = hex1b;
  };

  # `nix run .#hex1b` resolves the package and runs its meta.mainProgram — no
  # run-app needed. The root flake turns the `update` spec below into the
  # `update-hex1b` app (adds git + a cd into this dir).
  update = {
    runtimeInputs = [
      pkgs.cacert
      pkgs.coreutils
      pkgs.curl
      pkgs.findutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.gnutar
      pkgs.gzip
      pkgs.jq
      pkgs.nix
      pkgs.dotnetCorePackages.sdk_10_0
      pkgs.python3
    ];
    script = ./update.sh;
  };

  checks = import ./tests { inherit pkgs self; };

  devShellPackages = [ hex1b ];
}

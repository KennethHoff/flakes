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

  playwright = pkgs.callPackage ./package.nix {
    inherit (versions)
      version
      srcHash
      npmDepsHash
      chromiumRevision
      chromiumBrowserVersion
      chromiumHashes
      ffmpegRevision
      ffmpegHashes
      ;
  };
in
{
  # Primary package name — the auto-update workflow uses it as the Conventional
  # Commit scope (exposed repo-wide via lib.packageNames in the root flake).
  name = "playwright-cli";

  packages = {
    playwright-cli = playwright;
  };

  # `nix run .#playwright-cli` resolves the package and runs its meta.mainProgram
  # — no run-app needed. The root flake turns the `update` spec below into the
  # `update-playwright` app (adds git + a cd into this dir).
  update = {
    runtimeInputs = [
      pkgs.cacert
      pkgs.curl
      pkgs.gnutar
      pkgs.gzip
      pkgs.jq
      pkgs.nix
      pkgs.prefetch-npm-deps
    ];
    script = ./update.sh;
  };

  checks = import ./tests { inherit pkgs self; };

  devShellPackages = [ playwright ];
}

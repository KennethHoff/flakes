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
  # The Sentry CLI is FSL-1.1-Apache-2.0 (unfree in nixpkgs), so the package
  # needs allowUnfree to evaluate. Set it here on this tool's own pkgs; the
  # resulting derivation is blessed, so consumers that pull
  # `packages.<system>.sentry-cli` do not need allowUnfree in their own config.
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  versions = import ./versions.nix;

  sentry = pkgs.callPackage ./package.nix {
    inherit system;
    inherit (versions) version;
    hash = versions.hashes.${system};
  };
in
{
  packages = {
    sentry-cli = sentry;
  };

  # `nix run .#sentry-cli` resolves the package and runs its meta.mainProgram —
  # no run-app needed. The root flake turns the `update` spec below into the
  # `update-sentry-cli` app (adds git + a cd into this dir).
  update = {
    runtimeInputs = [
      pkgs.cacert
      pkgs.curl
      pkgs.jq
      pkgs.nix
    ];
    script = ./update.sh;
  };

  checks = import ./tests { inherit pkgs self; };

  devShellPackages = [ sentry ];
}

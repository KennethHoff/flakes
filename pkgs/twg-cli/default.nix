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
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  versions = import ./versions.nix;

  twg-cli = pkgs.callPackage ./package.nix {
    inherit (versions) version hashes;
  };
in
{
  packages = {
    inherit twg-cli;
  };

  # `nix run .#twg-cli` resolves the package and runs its meta.mainProgram
  # (`twg`). The root flake turns the `update` spec below into the
  # `update-twg-cli` app (adds git + a cd into this dir).
  update = {
    runtimeInputs = [
      pkgs.cacert
      pkgs.coreutils
      pkgs.curl
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.nix
    ];
    script = ./update.sh;
  };

  checks = import ./tests { inherit pkgs self; };

  devShellPackages = [ twg-cli ];
}

# Aggregates the per-check files in this directory. The root flake namespaces
# each key as `twg-cli-<key>`.
{ pkgs, self }:
let
  packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  versions = import ../versions.nix;

  # The package instantiated for any system, eval-only (never built).
  pkgFor =
    system:
    (import pkgs.path {
      inherit system;
      config.allowUnfree = true;
    }).callPackage
      ../package.nix
      { inherit (versions) version hashes; };

  args = { inherit pkgs packages pkgFor versions; };
in
{
  version = import ./version.nix args;
  helpRuns = import ./help-runs.nix args;
  versionOverride = import ./version-override.nix args;
  srcUrlPerSystem = import ./src-url-per-system.nix args;
  platforms = import ./platforms.nix args;
  unsupportedSystem = import ./unsupported-system.nix args;
  updateParses = import ./update-parses.nix args;
}

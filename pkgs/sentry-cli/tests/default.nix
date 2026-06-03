# Aggregates the per-check files in this directory. The root flake namespaces
# each key as `sentry-<key>`.
{ pkgs, self }:
let
  packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  args = { inherit pkgs packages; };
in
{
  version = import ./version.nix args;
  versionOverride = import ./version-override.nix args;
}

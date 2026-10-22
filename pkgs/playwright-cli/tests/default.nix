# Aggregates the per-check files in this directory. The root flake namespaces
# each key as `playwright-<key>`.
{ pkgs, self }:
let
  packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  args = { inherit pkgs packages; };
in
{
  version = import ./version.nix args;
  browser-opens = import ./browser-opens.nix args;
}
// pkgs.lib.optionalAttrs (packages.playwright-cli ? chromiumHeadlessShell) {
  headless-shell = import ./headless-shell.nix args;
}

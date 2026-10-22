# Aggregates the per-check files in this directory. The root flake namespaces
# each key as `playwright-<key>`.
{ pkgs, self }:
let
  packages = self.packages.${pkgs.stdenv.hostPlatform.system};
  args = { inherit pkgs packages; };
in
{
  version = import ./version.nix args;
}
# Only where a browser is bundled; aarch64-linux has none.
// pkgs.lib.optionalAttrs (packages.playwright-cli ? chromiumHeadlessShell) {
  browser-opens = import ./browser-opens.nix args;
  headless-shell = import ./headless-shell.nix args;
}

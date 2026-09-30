# Can't catch a corrupted Bun payload when the embedded Bun's version happens to
# equal twg's (a plain `bun -v` would then match); helpRuns guards that case.
{ pkgs, packages, ... }:
pkgs.runCommand "twg-cli-version-test"
  {
    twg = pkgs.lib.getExe packages.twg-cli;
    version = packages.twg-cli.version;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    [ "$("$twg" -v)" = "$version" ]

    mkdir -p "$out"
  ''

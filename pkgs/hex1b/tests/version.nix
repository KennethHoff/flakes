# The wrapped binary runs and reports the expected packaged version.
{ pkgs, packages }:
pkgs.runCommand "hex1b-version-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    hex1b = packages.hex1b;
    version = packages.hex1b.version;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    "$hex1b/bin/hex1b" --version | grep -qF "$version"

    mkdir -p "$out"
  ''

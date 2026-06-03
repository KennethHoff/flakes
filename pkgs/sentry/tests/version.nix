# Run the patched binary offline and check it reports the expected version.
# This also proves the interpreter/rpath fixups (and the appended Bun bundle)
# survived packaging — `--version` is purely local.
{ pkgs, packages }:
pkgs.runCommand "sentry-cli-version-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    sentry = packages.sentry-cli;
    version = packages.sentry-cli.version;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    "$sentry/bin/sentry" --version | grep -qF "$version"

    mkdir -p "$out"
  ''

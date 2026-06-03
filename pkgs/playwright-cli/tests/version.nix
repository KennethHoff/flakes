# The wrapped binary runs and reports the expected version. Also exercises the
# wrapper (browser env vars) and proves the build's bin actually launches.
{ pkgs, packages }:
pkgs.runCommand "playwright-cli-version-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    playwright = packages.playwright-cli;
    version = packages.playwright-cli.version;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    "$playwright/bin/playwright-cli" --version | grep -qF "$version"

    mkdir -p "$out"
  ''

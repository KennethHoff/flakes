# `playwright-cli` drives its bundled browser with nothing from the host: the
# build sandbox has no /lib64 loader, nix-ld, or system Chrome.
{ pkgs, packages }:
pkgs.runCommand "playwright-cli-browser-opens-test"
  {
    nativeBuildInputs = [ pkgs.gnugrep ];
    playwright = packages.playwright-cli;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"
    cd "$HOME"

    "$playwright/bin/playwright-cli" open 'data:text/html,<title>plug-n-play</title>' \
      | grep -qF 'Page Title: plug-n-play'
    "$playwright/bin/playwright-cli" close

    mkdir -p "$out"
  ''

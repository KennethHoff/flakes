# The passthru headless shell launches on its own, outside `playwright-cli`'s
# wrapper, and renders a page.
{ pkgs, packages }:
pkgs.runCommand "playwright-cli-headless-shell-test"
  {
    nativeBuildInputs = [ pkgs.gnugrep ];
    shell = pkgs.lib.getExe packages.playwright-cli.chromiumHeadlessShell;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    "$shell" --no-sandbox --disable-gpu --dump-dom \
      'data:text/html,<p id="probe">rendered</p>' \
      | grep -qF '<p id="probe">rendered</p>'

    mkdir -p "$out"
  ''

# The passthru headless shell launches on its own, outside `playwright-cli`'s
# wrapper, and renders a page, even with a caller's LD_LIBRARY_PATH carrying an
# unusable copy of one of its libraries.
{ pkgs, packages }:
pkgs.runCommand "playwright-cli-headless-shell-test"
  {
    nativeBuildInputs = [ pkgs.gnugrep ];
    shell = pkgs.lib.getExe packages.playwright-cli.chromiumHeadlessShell;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME" "$PWD/stray-libs"
    echo "not an ELF file" > "$PWD/stray-libs/libasound.so.2"
    export LD_LIBRARY_PATH="$PWD/stray-libs"

    "$shell" --no-sandbox --disable-gpu --dump-dom \
      'data:text/html,<p id="probe">rendered</p>' \
      | grep -qF '<p id="probe">rendered</p>'

    mkdir -p "$out"
  ''

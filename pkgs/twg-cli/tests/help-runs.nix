# `twg --help` exits 0 offline and shows twg's own help, not Bun's.
{ pkgs, packages, ... }:
pkgs.runCommand "twg-cli-help-test"
  {
    nativeBuildInputs = [ pkgs.gnugrep ];
    twg = pkgs.lib.getExe packages.twg-cli;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    mkdir -p "$HOME"

    "$twg" --help > help.txt
    grep -qF "Usage: twg [options] [command]" help.txt
    grep -qF "Teamwork Graph" help.txt

    mkdir -p "$out"
  ''

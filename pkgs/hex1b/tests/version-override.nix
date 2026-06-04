# `.override { version; }` flows through to the fetched source URL.
{ pkgs, packages }:
pkgs.runCommand "hex1b-version-override-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    baseUrl = packages.hex1b.src.url;
    overriddenUrl = (packages.hex1b.override { version = "0.0.0-test"; }).src.url;
  }
  ''
    set -euo pipefail

    echo "$overriddenUrl" | grep -q "v0\.0\.0-test\.tar\.gz"

    mkdir -p "$out"
  ''

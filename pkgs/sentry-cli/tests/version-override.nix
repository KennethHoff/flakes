# `.override { version; hash; }` flows through to the fetched src URL.
{ pkgs, packages }:
pkgs.runCommand "sentry-cli-version-override-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    baseUrl = packages.sentry-cli.src.url;
    overriddenUrl =
      (packages.sentry-cli.override {
        version = "0.0.0-test";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      }).src.url;
  }
  ''
    set -euo pipefail

    echo "$overriddenUrl" | grep -q "0\.0\.0-test"

    mkdir -p "$out"
  ''

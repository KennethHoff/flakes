# Each channel's binary runs and reports the expected version. aspire's
# `--version` prints the marketing version + commit (e.g. `13.3.5+<sha>`), which
# matches versions.nix `fileVersion`, not the full preview `version` string.
# Running all three also proves each channel built an executable.
{ pkgs, packages }:
let
  versions = import ../versions.nix;
in
pkgs.runCommand "aspire-cli-version-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    stable = packages.aspire-cli;
    staging = packages.aspire-cli_staging;
    dev = packages.aspire-cli_dev;
    stableVersion = versions.stable.fileVersion;
    stagingVersion = versions.staging.fileVersion;
    devVersion = versions.dev.fileVersion;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    export ASPIRE_CLI_TELEMETRY_OPTOUT=1
    mkdir -p "$HOME"

    "$stable/bin/aspire" --version | grep -qF "$stableVersion"
    "$staging/bin/aspire" --version | grep -qF "$stagingVersion"
    "$dev/bin/aspire" --version | grep -qF "$devVersion"

    mkdir -p "$out"
  ''

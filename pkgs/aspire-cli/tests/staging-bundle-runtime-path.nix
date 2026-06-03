# The wrapper copies the binary to $HOME/.local/state before exec, so the CLI's
# writable runtime layout must live there — never the read-only /nix/store.
{ pkgs, packages }:
pkgs.runCommand "aspire-cli-staging-runtime-path-test"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    staging = packages.aspire-cli_staging;
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    rm -rf "$HOME"
    mkdir -p "$HOME"

    # `update` now requires --yes under --non-interactive; it bails on a later
    # gate (--channel) but only after logging its layout, which is all we need.
    "$staging/bin/aspire" update --debug --non-interactive --yes >stdout 2>stderr || true

    # Upstream dropped the old .aspire-bundle-lock marker; the LayoutDiscovery
    # path under $HOME is the current proof of the same thing.
    grep -q "$HOME/.local/state/aspire-cli" stderr
    if grep -qE "(LayoutDiscovery|BundleService).*/nix/store" stderr; then
      echo "runtime layout unexpectedly rooted in /nix/store" >&2
      exit 1
    fi

    mkdir -p "$out"
  ''

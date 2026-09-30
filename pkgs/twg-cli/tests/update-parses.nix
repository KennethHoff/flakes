# update.sh against offline fixtures (TWG_BASE_URL=file://...): valid input
# yields the expected versions.nix; broken upstream data fails loudly and leaves
# an existing versions.nix untouched.
{ pkgs, ... }:
pkgs.runCommand "twg-cli-update-parses-test"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.curl
      pkgs.diffutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.nix
    ];
    script = ../update.sh;
    fixtures = ./fixtures;
    NIX_CONFIG = "experimental-features = nix-command";
  }
  ''
    set -euo pipefail

    export HOME="$PWD/home"
    export NIX_STATE_DIR="$PWD/nix-state" NIX_LOG_DIR="$PWD/nix-log" NIX_STORE_DIR="$PWD/nix-store"
    mkdir -p "$HOME"

    run() { # fixture-dir -> runs in a fresh dir seeded with a sentinel versions.nix
      rm -rf work && mkdir work && cd work
      echo sentinel > versions.nix
      set +e
      TWG_BASE_URL="file://$fixtures/$1" bash "$script" > ../out.log 2>&1
      rc=$?
      set -e
      cd ..
    }

    echo "--- (a) valid fixtures"
    run ok
    [ "$rc" = 0 ] || { cat out.log; echo "FAIL a: exit $rc" >&2; exit 1; }
    diff -u "$fixtures/expected-versions.nix" work/versions.nix

    echo "--- (b) no DEFAULT_VERSION line"
    run no-default-version
    [ "$rc" != 0 ] || { cat out.log; echo "FAIL b: exited 0" >&2; exit 1; }
    [ "$(cat work/versions.nix)" = sentinel ] || { echo "FAIL b: versions.nix modified" >&2; exit 1; }

    echo "--- (c) SHA256SUMS missing twg-darwin-arm64"
    run missing-darwin-arm64
    [ "$rc" != 0 ] || { cat out.log; echo "FAIL c: exited 0" >&2; exit 1; }
    [ "$(cat work/versions.nix)" = sentinel ] || { echo "FAIL c: versions.nix modified" >&2; exit 1; }

    mkdir -p "$out"
  ''

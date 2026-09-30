# An unsupported system fails evaluation loudly rather than fetching a wrong
# artifact. Eval-only; checks src.url only, since drvPath errors are uncatchable.
{ pkgs, pkgFor, ... }:
let
  result = builtins.tryEval (pkgFor "riscv64-linux").src.url;
in
pkgs.runCommand "twg-cli-unsupported-system-test" { } ''
  [ "${toString result.success}" = "" ] || { echo "riscv64-linux unexpectedly evaluated" >&2; exit 1; }
  mkdir -p "$out"
''

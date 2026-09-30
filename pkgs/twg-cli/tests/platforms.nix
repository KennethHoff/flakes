# meta.platforms is exactly the four supported systems, and versions.nix has a
# non-empty hash for each.
{
  pkgs,
  packages,
  versions,
  ...
}:
let
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
  platformsOk = builtins.sort builtins.lessThan packages.twg-cli.meta.platforms == systems;
  hashesOk = builtins.sort builtins.lessThan (builtins.attrNames versions.hashes) == systems;
  nonEmpty = builtins.all (s: pkgs.lib.hasPrefix "sha256-" versions.hashes.${s}) systems;
in
pkgs.runCommand "twg-cli-platforms-test" { } ''
  [ "${toString platformsOk}" = 1 ] || { echo "meta.platforms mismatch" >&2; exit 1; }
  [ "${toString hashesOk}" = 1 ] || { echo "versions.nix hashes keys mismatch" >&2; exit 1; }
  [ "${toString nonEmpty}" = 1 ] || { echo "versions.nix has a missing or non-SRI hash" >&2; exit 1; }
  mkdir -p "$out"
''

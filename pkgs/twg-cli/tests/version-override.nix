# `.override { version; hashes }` flows into the fetch URL.
{ pkgs, packages, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  overridden = packages.twg-cli.override {
    version = "0.0.0-test";
    hashes.${system} = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
  ok = pkgs.lib.hasInfix "-v0.0.0-test" overridden.src.url;
in
pkgs.runCommand "twg-cli-version-override-test" { } ''
  [ "${toString ok}" = 1 ] || { echo "src.url does not contain v0.0.0-test: ${overridden.src.url}" >&2; exit 1; }
  mkdir -p "$out"
''

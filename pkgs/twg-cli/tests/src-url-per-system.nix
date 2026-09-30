# Each supported system fetches the matching upstream artifact. Eval-only.
{
  pkgs,
  pkgFor,
  versions,
  ...
}:
let
  expected = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };
  bad = builtins.filter (
    system:
    (pkgFor system).src.url
    != "https://teamwork-graph.atlassian.com/cli/twg-${expected.${system}}-v${versions.version}"
  ) (builtins.attrNames expected);
in
pkgs.runCommand "twg-cli-src-url-per-system-test" { } ''
  [ "${toString (builtins.length bad)}" = 0 ] || { echo "wrong src url for: ${toString bad}" >&2; exit 1; }
  mkdir -p "$out"
''

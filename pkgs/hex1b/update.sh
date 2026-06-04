#!/usr/bin/env bash
set -euo pipefail

# Run via `nix run .#update-hex1b`. The wrapper provides curl, jq, nix, dotnet,
# and python on PATH; invoking this script directly requires those tools.

LATEST=$(curl -s "https://api.github.com/repos/mitchdenny/hex1b/releases/latest" | jq -r '.tag_name')
VERSION="${LATEST#v}"
URL="https://github.com/mitchdenny/hex1b/archive/refs/tags/${LATEST}.tar.gz"

SRC_HASH=$(nix store prefetch-file --json "$URL" | jq -r .hash)

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -sL "$URL" | tar -xz -C "$tmpdir" --strip-components=1

packagesDir="$tmpdir/nuget-packages"
dotnet restore "$tmpdir/src/Hex1b.Tool/Hex1b.Tool.csproj" --packages "$packagesDir" >/dev/null
dotnet restore "$tmpdir/tests/Hex1b.Tool.Tests/Hex1b.Tool.Tests.csproj" --packages "$packagesDir" >/dev/null

python <<'PY' "$tmpdir" > deps.json
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
packages = root / "nuget-packages"
asset_files = [
    root / "src/Hex1b.Tool/obj/project.assets.json",
    root / "tests/Hex1b.Tool.Tests/obj/project.assets.json",
]

libs = {}
for af in asset_files:
    data = json.loads(af.read_text())
    for key, value in data.get("libraries", {}).items():
        if value.get("type") != "package":
            continue
        name, ver = key.split("/", 1)
        libs[(name, ver)] = True

rows = []
for name, ver in sorted(libs):
    sha_file = packages / name.lower() / ver.lower() / f"{name.lower()}.{ver.lower()}.nupkg.sha512"
    if not sha_file.exists():
        raise SystemExit(f"missing hash file for {name} {ver}: {sha_file}")
    b64 = sha_file.read_text().strip()
    rows.append({"pname": name, "version": ver, "hash": f"sha512-{b64}"})

print(json.dumps(rows, indent=2))
PY

cat > versions.nix <<VERS
{
  version = "${VERSION}";
  srcHash = "${SRC_HASH}";
}
VERS

echo "Updated to ${VERSION}"

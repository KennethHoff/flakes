#!/usr/bin/env bash
set -euo pipefail

CHANNELS=("${@:-stable staging dev}")
if [[ $# -eq 0 ]]; then
  CHANNELS=(stable staging dev)
fi

SYSTEMS=("x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin")

declare -A PLATFORM_MAP=(
  [x86_64-linux]="linux-x64"
  [aarch64-linux]="linux-arm64"
  [x86_64-darwin]="osx-x64"
  [aarch64-darwin]="osx-arm64"
)

resolve_url() {
  local channel="$1" platform="$2"
  case "$channel" in
    stable)  echo "https://aka.ms/dotnet/9/aspire/ga/daily/aspire-cli-${platform}.tar.gz" ;;
    staging) echo "https://aka.ms/dotnet/9/aspire/rc/daily/aspire-cli-${platform}.tar.gz" ;;
    dev)     echo "https://aka.ms/dotnet/9/aspire/daily/aspire-cli-${platform}.tar.gz" ;;
    *)       echo "Unknown channel: $channel" >&2; exit 1 ;;
  esac
}

# Written to the current working directory. The `update-aspire-cli` wrapper cd's
# into this tool's dir (resolved from the repo root) first, so a plain
# `nix run .#update-aspire-cli` targets pkgs/aspire-cli/versions.nix from anywhere.
VERSIONS_FILE="$PWD/versions.nix"

# Build the new versions.nix content
output="{\n"

for channel in "${CHANNELS[@]}"; do
  echo "=== Updating $channel channel ==="

  # Resolve version from the first platform (linux-x64)
  redirect_url=$(resolve_url "$channel" "linux-x64")
  echo "Resolving latest version from $channel channel..."
  tarball_url=$(curl -sL -o /dev/null -w '%{url_effective}\n' "$redirect_url")
  version=$(echo "$tarball_url" | sed -n 's#^.*/public/aspire/\([^/]*\)/.*#\1#p')

  if [[ -z "$version" ]]; then
    echo "Failed to resolve version for $channel" >&2
    exit 1
  fi

  echo "Found version: $version"

  # Extract fileVersion from the tarball filename
  file_version=$(basename "$tarball_url" .tar.gz | sed 's/^aspire-cli-linux-x64-//' | sed 's/^aspire-cli-linux-x64$//')
  file_version="${file_version:-$version}"

  current_version=$(sed -n "/^  $channel = {/,/};/{s/.*version = \"\([^\"]*\)\".*/\1/p;}" "$VERSIONS_FILE")
  if [[ "$version" == "$current_version" ]]; then
    echo "$channel is already up to date."
  fi

  output+="  $channel = {\n"
  output+="    version = \"$version\";\n"

  output+="    fileVersion = \"$file_version\";\n"

  output+="    hashes = {\n"

  for sys in "${SYSTEMS[@]}"; do
    platform="${PLATFORM_MAP[$sys]}"
    url="https://ci.dot.net/public/aspire/${version}/aspire-cli-${platform}-${file_version}.tar.gz"
    echo "  Fetching hash for $sys ($platform)..."
    hash=$(nix-prefetch-url --type sha512 "$url" 2>/dev/null | xargs nix hash convert --hash-algo sha512 --to sri)
    echo "    $hash"
    output+="      $sys = \"$hash\";\n"
  done

  output+="    };\n"
  output+="  };\n"

  echo "Updated $channel to version $version"
done

output+="}\n"

echo -e "$output" > "$VERSIONS_FILE"

echo "Done."

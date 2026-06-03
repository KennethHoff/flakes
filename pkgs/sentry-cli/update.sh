#!/usr/bin/env bash
set -euo pipefail

# Run via `nix run .#update`. The wrapper provides curl, jq, and nix on PATH;
# invoking this script directly requires those tools installed already.

# Latest stable release tag from GitHub. Tags are bare versions like "0.35.0".
LATEST=$(curl -s "https://api.github.com/repos/getsentry/cli/releases/latest" \
  | jq -r '.tag_name')

echo "Latest version: $LATEST"

declare -A PLATFORM_MAP=(
  [x86_64-linux]="linux-x64"
  [aarch64-linux]="linux-arm64"
  [x86_64-darwin]="darwin-x64"
  [aarch64-darwin]="darwin-arm64"
)

prefetch() {
  nix store prefetch-file --json "$1" | jq -r .hash
}

# Per-platform sha256 of the bare gzipped binaries published on the GitHub
# release (sentry-<platform>.gz).
declare -A H
for SYS in x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin; do
  PLATFORM="${PLATFORM_MAP[$SYS]}"
  URL="https://github.com/getsentry/cli/releases/download/${LATEST}/sentry-${PLATFORM}.gz"
  echo "  hashing ${SYS} (${PLATFORM})..."
  H[$SYS]=$(prefetch "$URL")
done

cat > versions.nix <<EOF
{
  version = "${LATEST}";
  hashes = {
    x86_64-linux = "${H[x86_64-linux]}";
    aarch64-linux = "${H[aarch64-linux]}";
    x86_64-darwin = "${H[x86_64-darwin]}";
    aarch64-darwin = "${H[aarch64-darwin]}";
  };
}
EOF

echo "Done."

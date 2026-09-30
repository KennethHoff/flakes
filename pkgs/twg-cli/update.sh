#!/usr/bin/env bash
set -euo pipefail

# Run via `nix run .#update-twg-cli`. The wrapper provides curl, coreutils,
# grep, sed, and nix on PATH; invoking this script directly requires those
# tools installed already.

BASE="${TWG_BASE_URL:-https://teamwork-graph.atlassian.com/cli}"

LATEST=$(curl -fsS "$BASE/install" \
  | sed -n 's/^DEFAULT_VERSION="\([^"]*\)".*/\1/p' | head -n1)
[ -n "$LATEST" ] || { echo "could not scrape DEFAULT_VERSION" >&2; exit 1; }

echo "Latest version: $LATEST"

SUMS=$(curl -fsS "$BASE/SHA256SUMS-v${LATEST}")

sri() {
  local file="twg-$1-v${LATEST}" hex
  hex=$(printf '%s\n' "$SUMS" | awk -v f="$file" '$2 == f { print $1 }')
  [ -n "$hex" ] || { echo "no checksum for $file" >&2; return 1; }
  nix hash convert --hash-algo sha256 --from base16 --to sri "$hex"
}

# Assigned outside the heredoc so a failure aborts under `set -e` before
# versions.nix is touched.
X86_64_LINUX=$(sri linux-x64)
AARCH64_LINUX=$(sri linux-arm64)
X86_64_DARWIN=$(sri darwin-x64)
AARCH64_DARWIN=$(sri darwin-arm64)

cat > versions.nix <<NIX
{
  version = "${LATEST}";

  # From https://teamwork-graph.atlassian.com/cli/SHA256SUMS-v<version>, converted to SRI.
  hashes = {
    x86_64-linux = "${X86_64_LINUX}";
    aarch64-linux = "${AARCH64_LINUX}";
    x86_64-darwin = "${X86_64_DARWIN}";
    aarch64-darwin = "${AARCH64_DARWIN}";
  };
}
NIX

echo "Done."

#!/usr/bin/env bash
set -euo pipefail

# Run via `nix run .#update`. The wrapper provides curl, jq, gnutar, and
# prefetch-npm-deps on PATH; invoking this script directly requires those
# tools installed already.

# Fetch the latest release tag from GitHub
LATEST=$(curl -s "https://api.github.com/repos/microsoft/playwright-cli/releases/latest" \
  | grep '"tag_name"' | sed 's/.*"tag_name": *"v\([^"]*\)".*/\1/')

echo "Latest version: $LATEST"

# Compute srcHash
SRC_HASH=$(nix store prefetch-file --unpack --json \
  "https://github.com/microsoft/playwright-cli/archive/refs/tags/v${LATEST}.tar.gz" \
  | grep '"hash"' | sed 's/.*"hash": *"\([^"]*\)".*/\1/')

echo "srcHash: $SRC_HASH"

# Fetch source tarball to get package-lock.json and the bundled playwright-core
# version that ships with this CLI release.
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -sL "https://github.com/microsoft/playwright-cli/archive/refs/tags/v${LATEST}.tar.gz" \
  | tar xz -C "$TMP"

LOCK_FILE="$TMP/playwright-cli-${LATEST}/package-lock.json"

# Compute npmDepsHash
NPM_DEPS_HASH=$(prefetch-npm-deps "$LOCK_FILE")

echo "npmDepsHash: $NPM_DEPS_HASH"

# Read playwright-core version from package-lock.json, pull its npm tarball,
# and extract browsers.json to determine the Chromium revision + browserVersion.
PW_CORE_VER=$(jq -r '.packages["node_modules/playwright-core"].version' "$LOCK_FILE")
echo "playwright-core: $PW_CORE_VER"

curl -sL "https://registry.npmjs.org/playwright-core/-/playwright-core-${PW_CORE_VER}.tgz" \
  | tar xz -C "$TMP"

BROWSERS_JSON="$TMP/package/browsers.json"
CHROMIUM_REV=$(jq -r '.browsers[] | select(.name=="chromium") | .revision' "$BROWSERS_JSON")
CHROMIUM_VER=$(jq -r '.browsers[] | select(.name=="chromium") | .browserVersion' "$BROWSERS_JSON")

echo "chromiumRevision: $CHROMIUM_REV"
echo "chromiumBrowserVersion: $CHROMIUM_VER"

# ffmpeg revision (Playwright records video through this binary).
FFMPEG_REV=$(jq -r '.browsers[] | select(.name=="ffmpeg") | .revision' "$BROWSERS_JSON")
echo "ffmpegRevision: $FFMPEG_REV"

# Per-platform sha256 of chrome + chrome-headless-shell zips.
# Chrome for Testing does not publish linux-arm64; aarch64-linux is excluded.
prefetch() {
  local url="$1"
  nix store prefetch-file --json "$url" | jq -r .hash
}

declare -A H
for PLATFORM in linux64 mac-x64 mac-arm64; do
  for ZIP in chrome chrome-headless-shell; do
    URL="https://cdn.playwright.dev/builds/cft/${CHROMIUM_VER}/${PLATFORM}/${ZIP}-${PLATFORM}.zip"
    echo "  hashing ${ZIP} ${PLATFORM}..."
    H["${PLATFORM}_${ZIP}"]=$(prefetch "$URL")
  done
done

# Per-platform sha256 of the ffmpeg zips. linux-arm64 is excluded to match the
# chromium platform set above.
declare -A F
for FF in ffmpeg-linux ffmpeg-mac ffmpeg-mac-arm64; do
  URL="https://cdn.playwright.dev/builds/ffmpeg/${FFMPEG_REV}/${FF}.zip"
  echo "  hashing ${FF}..."
  F["${FF}"]=$(prefetch "$URL")
done

# Write versions.nix
cat > versions.nix <<EOF
{
  version = "${LATEST}";
  srcHash = "${SRC_HASH}";
  npmDepsHash = "${NPM_DEPS_HASH}";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "${CHROMIUM_REV}";
  chromiumBrowserVersion = "${CHROMIUM_VER}";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "${H[linux64_chrome]}";
      headless = "${H[linux64_chrome-headless-shell]}";
    };
    x86_64-darwin = {
      chromium = "${H[mac-x64_chrome]}";
      headless = "${H[mac-x64_chrome-headless-shell]}";
    };
    aarch64-darwin = {
      chromium = "${H[mac-arm64_chrome]}";
      headless = "${H[mac-arm64_chrome-headless-shell]}";
    };
  };

  # ffmpeg revision shipped with this playwright-cli release (read from
  # playwright-core/browsers.json). Playwright records video through this
  # binary at \$PLAYWRIGHT_BROWSERS_PATH/ffmpeg-<revision>/ffmpeg-<platform>.
  ffmpegRevision = "${FFMPEG_REV}";

  # Per-platform sha256 of the ffmpeg zips from
  # https://cdn.playwright.dev/builds/ffmpeg/<ffmpegRevision>/ffmpeg-<platform>.zip
  ffmpegHashes = {
    x86_64-linux = "${F[ffmpeg-linux]}";
    x86_64-darwin = "${F[ffmpeg-mac]}";
    aarch64-darwin = "${F[ffmpeg-mac-arm64]}";
  };
}
EOF

echo "Done."

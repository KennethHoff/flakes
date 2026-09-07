{
  version = "0.1.19";
  srcHash = "sha256-pbv51ybubbjoIpKg0k7lfXfZ9Z+qdZI2lRhQeI+/mFA=";
  npmDepsHash = "sha256-aY3i+sc2p8iQAEpfs+j/ifeBVmMpDDmwctEqOIDmCqI=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1243";
  chromiumBrowserVersion = "153.0.8010.12";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-iqw1ARwY9uLRBpYVSviaVyisLd1txvrST/3yQ8P8/Vo=";
      headless = "sha256-qdoCiGGgz3if8lwv7UX18ar5ae2SR4NbanghpPevnR0=";
    };
    x86_64-darwin = {
      chromium = "sha256-ThLiuKKXout5wWJY5Glhxz+Kovpr5rHTzbtVP7XU7xw=";
      headless = "sha256-XC6qGq1iERu1pw3QiJ3TCT8xQid7j3iVeiOCV+6F8Ak=";
    };
    aarch64-darwin = {
      chromium = "sha256-kw4qLBWt26yh/psHv6UgZnvO1VbXmIcHGGgZy0J57zs=";
      headless = "sha256-idgKbSbM0Mz9UeItnhKXKDhirysM2R3OB0WbNcoAWfI=";
    };
  };

  # ffmpeg revision shipped with this playwright-cli release (read from
  # playwright-core/browsers.json). Playwright records video through this
  # binary at $PLAYWRIGHT_BROWSERS_PATH/ffmpeg-<revision>/ffmpeg-<platform>.
  ffmpegRevision = "1011";

  # Per-platform sha256 of the ffmpeg zips from
  # https://cdn.playwright.dev/builds/ffmpeg/<ffmpegRevision>/ffmpeg-<platform>.zip
  ffmpegHashes = {
    x86_64-linux = "sha256-68dPxblIMBdqPCkUrpa9i8f2qR9PM4kCMPhKFy7mHMw=";
    x86_64-darwin = "sha256-F+0Vovpg08dBgb78sr33ybsojRmyo7mJO5S2PyziYOQ=";
    aarch64-darwin = "sha256-fXfrDUS1msxAZfqiR2wN8aJCzJBMNG+CBiaBjJU8Unc=";
  };
}

{
  version = "0.1.24";
  srcHash = "sha256-7dKRvxQ+ntqr4JPqGoWN+CHEZVg6E6Q/hO6EA6DXDKA=";
  npmDepsHash = "sha256-MWBo2GleWToU5Z7c6njOIWaWzcmokY5wf6FRxHqw4H4=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1254";
  chromiumBrowserVersion = "158.0.8127.18";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-xssG4VdKwvbFw44xVRFX+8qmfmNmyJl0CEVTxaV3JZI=";
      headless = "sha256-GDUtIssM31IMv/KtjEE5Hw4CpyiGy1Ow/eS9/EvQddY=";
    };
    x86_64-darwin = {
      chromium = "sha256-ggjMTTyaBvuJPgKBgPrAGerHCSgUqqyLD9mo2C+x0Wg=";
      headless = "sha256-gdZJbE6bfGqfjZyxi+70fX2o6yNdHVCJ9zhdGcHjeL4=";
    };
    aarch64-darwin = {
      chromium = "sha256-FdVHg9QHMpg2U+vCFxrzjGtbWrBVqa+/SNR8K1eDbak=";
      headless = "sha256-80Jh0qrZT7cbM2WXrKvyAWbuWi8UkmxzHzPQTF2mzT8=";
    };
  };

  # ffmpeg revision shipped with this playwright-cli release (read from
  # playwright-core/browsers.json). Playwright records video through this
  # binary at $PLAYWRIGHT_BROWSERS_PATH/ffmpeg-<revision>/ffmpeg-<platform>.
  ffmpegRevision = "1013";

  # Per-platform sha256 of the ffmpeg zips from
  # https://cdn.playwright.dev/builds/ffmpeg/<ffmpegRevision>/ffmpeg-<platform>.zip
  ffmpegHashes = {
    x86_64-linux = "sha256-7phkNNFY90+12cX/EJICbO7bY/Mk/pC1volGCSa3tnk=";
    x86_64-darwin = "sha256-/98IqxPe8rY+ge2XguOd68W9SYIg6OE0+aNumE222ds=";
    aarch64-darwin = "sha256-Y+SM6NSm2dSWOD5axVeyZGbnGfopEmu71fX3AWrJIpw=";
  };
}

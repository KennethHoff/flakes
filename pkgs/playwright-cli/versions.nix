{
  version = "0.1.14";
  srcHash = "sha256-wLE04sfPMh43IzIp6/HKBjloy3iSSanSYdYtklc6lQ4=";
  npmDepsHash = "sha256-0bvwryiyPskay+h8+0RiOmnamHkmcRRK00q7ZEPdj1g=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1226";
  chromiumBrowserVersion = "149.0.7827.22";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-adPeAWwebgSD/g14lUtm9G/UQEy1kAl4oo3yJlcHEZQ=";
      headless = "sha256-bXqpfNO770Wn/AM81488gRK0QxLqEef0EDdWBPi5KH4=";
    };
    x86_64-darwin = {
      chromium = "sha256-slSSSKqZHVWGEkDN3LbpP7Xcg55TOMZQm3Ce2gFNoa4=";
      headless = "sha256-p0aHFd7QUYQ9+G/hJgYFNHpq22CPZLDafCbNAj7tNLg=";
    };
    aarch64-darwin = {
      chromium = "sha256-J283kcbw50JP/C41fvaL3TdAxj0Zu+4uyPwPrCwu/QA=";
      headless = "sha256-0Bs2hLoUovOCslWl+bbXMwSgeVDWH+e1w8SjAlWfOqQ=";
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

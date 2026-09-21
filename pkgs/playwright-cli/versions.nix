{
  version = "0.1.21";
  srcHash = "sha256-ZHfQBZQejJKNYfhszd99i4GIzEpomBzX0/HkMK2T8DQ=";
  npmDepsHash = "sha256-aTn5CFeAzoH4J+TYiM4HOULzWAeyU3xmD4wkQdsJrGY=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1246";
  chromiumBrowserVersion = "154.0.8037.0";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-ZTciFj1Y75mKAoNS25/+mgOMk3rLiWK2q+T/r8L7d/U=";
      headless = "sha256-2YgWuZKEeVFhAaaZE371UfbSHJqtVPOmqlQbsb1h56I=";
    };
    x86_64-darwin = {
      chromium = "sha256-kYfydZGM397u1uQbm5Do9U0+7p6dCLdNl1qJxjPWiHY=";
      headless = "sha256-tZxK8u6Stc6jmwytYuQNUs4DRlpfVZIrVailc38/U4c=";
    };
    aarch64-darwin = {
      chromium = "sha256-CHq/fZQFveF4ibTMvn0S9KTRKgFkzAh/7dO/5GgXuqc=";
      headless = "sha256-nUeQAQ5WoDRZO3fJ5ZlDU4hbwt/2iP6IynGs7Zsoi9c=";
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

{
  version = "0.1.22";
  srcHash = "sha256-80xzHvf7BHGvoKvMdkGeNUsUrpZrpw5eryuQM8NKT/E=";
  npmDepsHash = "sha256-mGD7a/v1cx/xPGZo8nN3WA40mYGgF/KzMKiGbvUeX4E=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1247";
  chromiumBrowserVersion = "155.0.8059.12";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-okVG4ObHY7+GSGHOUEmPOHg2Y+JM0q8qFnmMJdw6lIk=";
      headless = "sha256-rrkoOUPvHyGGTqQq0SAbifW89qhMPj0NZBUp0lGRS+0=";
    };
    x86_64-darwin = {
      chromium = "sha256-WAs+piMd9cuXYOJ6iJ394h85GtvVhCnXK+RoT3iehoI=";
      headless = "sha256-LFn0q/3OTakJXjnsrSni2vUTDJxM7vPYRwpfvBCra/4=";
    };
    aarch64-darwin = {
      chromium = "sha256-1kdxoJb//Ui0mmXkgd2lCuQ6feVfuTrPpq7OJuw7ENs=";
      headless = "sha256-+3XPFZ9L1diA4OqVYAhY9kBNV8kEiq5xwS2n7lmiaDY=";
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

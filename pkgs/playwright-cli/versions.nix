{
  version = "0.1.15";
  srcHash = "sha256-M0NZ7h1kSIsxktMWe5n75LDc+MHZvSq6b+iRx6opakU=";
  npmDepsHash = "sha256-ZrO8yIqMYMQUlsQraejVgKRZ7klC5/8UsV3/H1EqYtA=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1229";
  chromiumBrowserVersion = "150.0.7871.24";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-4N1XIa6H/HQyKzcOdPgVwUY1fr5Crxdvju4/eIsuwB0=";
      headless = "sha256-b52s85PZnDEVqIp73emRZ6ksmFbL0cIYfKds1HHVoto=";
    };
    x86_64-darwin = {
      chromium = "sha256-/wE9IpjB/fAZ5sxNOMn22f5F6g6HyJFALcEvIbAuqFk=";
      headless = "sha256-dsaBSsLtAs6DHoJuORRKldjq0cl7M2mrTQYsraXxr/A=";
    };
    aarch64-darwin = {
      chromium = "sha256-HQybKGfMML6te9RGjspVC/gmBSZ5xfe/+RrVJ6p1f8s=";
      headless = "sha256-3AxBmHvpJnc9ueEuZSELBPrEbe98LtpMTrF1oMRpHmo=";
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

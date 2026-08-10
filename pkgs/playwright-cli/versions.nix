{
  version = "0.1.18";
  srcHash = "sha256-E/AzDJhD12PWSaA3iRY+hloPsSWnAw18gTa/ItVhr3E=";
  npmDepsHash = "sha256-3kqiQvGtZfsmLHVWeCSM1yOYb+ws2x1vMPC1OuvrKAI=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1237";
  chromiumBrowserVersion = "152.0.7977.8";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-kxhllRoo/M8Ekaf14KL+GgYFdlIQpM5KR1jZ09l9C3c=";
      headless = "sha256-lhXAwlV7YUqHYF5xSTcu9Qz/j+jFLn67hV79DOprFQE=";
    };
    x86_64-darwin = {
      chromium = "sha256-0vbxuBcDLfvAP4D6ME86LpFycpPObnlrJI5IPd6jIJk=";
      headless = "sha256-cMH91u0D/NDHTQRvsgjiwUmrLkgwb928ZY0+17b0IZU=";
    };
    aarch64-darwin = {
      chromium = "sha256-eFcLsjx0QvWBwrXxyGw+g7aLbNNUJM85Ct1RoeMFOYs=";
      headless = "sha256-55QvvB0SEaF+1F8YfruV2CzzwboJKlyZLJcPgPlqx34=";
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

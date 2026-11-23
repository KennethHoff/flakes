{
  version = "0.1.25";
  srcHash = "sha256-WCtATa/1WKl7XJxvgrbgslKdH0vh4Bf/p6VX3nGC9rQ=";
  npmDepsHash = "sha256-sewzAMYMgoJTIwK/Jlejhlxh3dyozlAzfD2czioCWAo=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1255";
  chromiumBrowserVersion = "159.0.8154.6";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-NwYBEGwbVhmq5fBvej/cYINkhhNZNHeUYeKiCNd39ZY=";
      headless = "sha256-d6ZEL9PIrNO++eEGf8JvXvRkJ30i8OjLWNw+QHej5Fg=";
    };
    x86_64-darwin = {
      chromium = "sha256-aGQQmqQjeF1dXVL9BrwROOArAC/NQAlVogETWMWoMh8=";
      headless = "sha256-icVvsICrTpunZlbVZpryst/DE8EUNIcej041HAil/8o=";
    };
    aarch64-darwin = {
      chromium = "sha256-Q2CWdqQeKdHHZnk165FKQi7KmLLkncv9bz6XlCAt4So=";
      headless = "sha256-sI576vAqGeLuXtaVX5w4U6uRds1btXuoevu4Lp+BzCk=";
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

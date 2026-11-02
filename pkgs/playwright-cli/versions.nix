{
  version = "0.1.23";
  srcHash = "sha256-MqeB9U8676YOlB6JbX5Dcp2PeWftQcmbTUPp9dS5t+U=";
  npmDepsHash = "sha256-GQjH0Zwf9cYuuM6m4mM2Xwz6qWuJTsXsj0nCSm71BlY=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1252";
  chromiumBrowserVersion = "157.0.8103.15";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-q53QuhA755zGApYtiyHihfJnMaURXBp1mggU2hNGtU0=";
      headless = "sha256-VjUmsZwRmtqtT7xgM5WpBdbdY3VB3Y7XBjWxisG7ilM=";
    };
    x86_64-darwin = {
      chromium = "sha256-pDJfDt8w7R3b95yMGD3m+QSc55s1gsn+Ireln0gqO8g=";
      headless = "sha256-AZ6kJ+cvgLwxUUHT5+MZlecMjszap5C3bpPfrobOSik=";
    };
    aarch64-darwin = {
      chromium = "sha256-/el194E7fU/Yo9tTG82v+kWCd+GPhao7H8Dm1IDrNcQ=";
      headless = "sha256-wRnt4Vm2p5lKCS8sdpZBfPI9l3y+BZMeCiig+esOuZM=";
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

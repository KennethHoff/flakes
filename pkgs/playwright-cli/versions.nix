{
  version = "0.1.13";
  srcHash = "sha256-hHK/GR5Drlt+e0L9kyNmn+ht1PCrVH6WrVbxGB1Wsxg=";
  npmDepsHash = "sha256-Ulp6IttsZcOOA7LaYDpVKkBYbe2j4RFG8lJARWifOSk=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1224";
  chromiumBrowserVersion = "149.0.7827.3";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-T137sJzBA1c74gHocFc/5T82sd4HasZJBJxCG7WzHmk=";
      headless = "sha256-H1bDOoKIEhLXCHSLmXUpLUCrQDt8ruFkUeMuq+yUwMs=";
    };
    x86_64-darwin = {
      chromium = "sha256-h6xcdQVTNcB+bSZUTAPlYIg7l228D6XWyJaXMretJFU=";
      headless = "sha256-qWIrl88pXXrkLSAtKDJ1m2SM4reIQ2TVNmy3qE3YNlU=";
    };
    aarch64-darwin = {
      chromium = "sha256-4KPf306tFDi0oA5rtzozZDgz73JtwJHZaU35/DRxCQw=";
      headless = "sha256-+1v5W/QkKENinVT5YIMhOtbIJ/1C/0N4etMmj5TK7do=";
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

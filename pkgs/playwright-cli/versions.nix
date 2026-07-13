{
  version = "0.1.17";
  srcHash = "sha256-tc/2Qck3mm6BqWTu2lvvfsM0/BHO/Z0ZvCdFZ7QQqKI=";
  npmDepsHash = "sha256-u44jWprmr3RdzB3aDL3K0ShT5lLxr175z3C8pN43YFA=";

  # Chromium revision + Chrome for Testing browserVersion shipped with this
  # playwright-cli release (read from playwright-core/browsers.json).
  chromiumRevision = "1232";
  chromiumBrowserVersion = "151.0.7922.10";

  # Per-platform sha256 of the chrome + chrome-headless-shell zips from
  # https://cdn.playwright.dev/builds/cft/<chromiumBrowserVersion>/<platform>/
  # linux-arm64 is not published by Chrome for Testing upstream.
  chromiumHashes = {
    x86_64-linux = {
      chromium = "sha256-JztIc0wJuxcd/mfwdmwMIzPyOU2hPb5EBQN3vxhn2aI=";
      headless = "sha256-2QjHDANW3XReibTXiG4yW7PbbtGWMzyv4TDFo1NhIEo=";
    };
    x86_64-darwin = {
      chromium = "sha256-8xGh6TMdPnUER9wkJOI4kYyK5WE2v0WNCxftCghotjo=";
      headless = "sha256-3vydyxjkIf2+a0oTsFXKXw4sq2LlVvK2gBtVm64iK38=";
    };
    aarch64-darwin = {
      chromium = "sha256-Nm7nfVxs0/xi+n+NjW8+o61jYIANnasnoegeIhEJRhQ=";
      headless = "sha256-HsryUs7B1AdxM9v3684g4LuacWZAEmUA8AsfeMraNMM=";
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

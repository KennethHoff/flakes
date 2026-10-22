{
  lib,
  autoPatchelfHook,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  symlinkJoin,
  unzip,
  stdenv,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gobject-introspection,
  gtk3,
  libdrm,
  libgbm,
  libpulseaudio,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  udev,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  version,
  srcHash,
  npmDepsHash,
  chromiumRevision,
  chromiumBrowserVersion,
  chromiumHashes,
  ffmpegRevision,
  ffmpegHashes,
}:
let
  # Chrome for Testing platform tag for the current host.
  cftPlatform =
    {
      "x86_64-linux" = "linux64";
      "x86_64-darwin" = "mac-x64";
      "aarch64-darwin" = "mac-arm64";
    }
    .${stdenv.hostPlatform.system} or null;

  hostHashes = chromiumHashes.${stdenv.hostPlatform.system} or null;

  # Playwright ffmpeg platform tag for the current host. The unzipped binary is
  # named ffmpeg-<tag> and Playwright looks it up at
  # <out>/ffmpeg-<revision>/ffmpeg-<tag>.
  ffmpegPlatform =
    {
      "x86_64-linux" = "ffmpeg-linux";
      "x86_64-darwin" = "ffmpeg-mac";
      "aarch64-darwin" = "ffmpeg-mac-arm64";
    }
    .${stdenv.hostPlatform.system} or null;

  ffmpegHostHash = ffmpegHashes.${stdenv.hostPlatform.system} or null;

  # Build one browser dir matching Playwright's expected on-disk layout:
  # <out>/<dirName>-<revision>/<zip-toplevel>/  plus marker files.
  mkBrowser =
    {
      zipName,
      dirName,
      hash,
      mainProgram ? null,
    }:
    stdenvNoCC.mkDerivation {
      pname = "playwright-${dirName}";
      version = chromiumRevision;
      src = fetchurl {
        url = "https://cdn.playwright.dev/builds/cft/${chromiumBrowserVersion}/${cftPlatform}/${zipName}-${cftPlatform}.zip";
        inherit hash;
      };
      # Chrome for Testing links against the FHS loader (/lib64/ld-linux-*),
      # which a NixOS host only has through nix-ld and a build sandbox never.
      nativeBuildInputs = [
        unzip
      ]
      ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ]
      ++ lib.optionals (mainProgram != null) [ makeWrapper ];
      buildInputs = browserDeps;
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p "$out/${dirName}-${chromiumRevision}"
        unzip -q "$src" -d "$out/${dirName}-${chromiumRevision}"
        touch "$out/${dirName}-${chromiumRevision}/INSTALLATION_COMPLETE"
        touch "$out/${dirName}-${chromiumRevision}/DEPENDENCIES_VALIDATED"
      ''
      # LD_LIBRARY_PATH outranks the patched RUNPATH, so a caller's own (say, a
      # libasound built against a newer glibc) would otherwise be loaded first.
      + lib.optionalString (mainProgram != null) ''
        makeWrapper \
          "$out/${dirName}-${chromiumRevision}/${zipName}-${cftPlatform}/${mainProgram}" \
          "$out/bin/${mainProgram}" \
          ${lib.optionalString stdenv.isLinux ''--prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath browserDeps}"''}
      ''
      + ''
        runHook postInstall
      '';
      meta = lib.optionalAttrs (mainProgram != null) { inherit mainProgram; };
    };

  # Build the ffmpeg dir matching Playwright's expected on-disk layout:
  # <out>/ffmpeg-<revision>/ffmpeg-<platform>  plus marker file. The ffmpeg
  # zip contains the bare binary (no top-level subdir), so it unzips straight
  # into the revision dir.
  ffmpegDir = stdenvNoCC.mkDerivation {
    pname = "playwright-ffmpeg";
    version = ffmpegRevision;
    src = fetchurl {
      url = "https://cdn.playwright.dev/builds/ffmpeg/${ffmpegRevision}/${ffmpegPlatform}.zip";
      hash = ffmpegHostHash;
    };
    nativeBuildInputs = [ unzip ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/ffmpeg-${ffmpegRevision}"
      unzip -q "$src" -d "$out/ffmpeg-${ffmpegRevision}"
      touch "$out/ffmpeg-${ffmpegRevision}/INSTALLATION_COMPLETE"
      runHook postInstall
    '';
  };

  # Also exposed on its own, for a Playwright client (another language binding,
  # another version) to launch via executablePath; such a client looks for its
  # own revision's directory, so PLAYWRIGHT_BROWSERS_PATH alone doesn't reach it.
  chromiumHeadlessShell = mkBrowser {
    zipName = "chrome-headless-shell";
    dirName = "chromium_headless_shell";
    hash = hostHashes.headless;
    mainProgram = "chrome-headless-shell";
  };

  browsersDir =
    lib.optionalAttrs
      (cftPlatform != null && hostHashes != null && ffmpegPlatform != null && ffmpegHostHash != null)
      {
        out = symlinkJoin {
          name = "playwright-browsers-cft-${chromiumBrowserVersion}";
          paths = [
            (mkBrowser {
              zipName = "chrome";
              dirName = "chromium";
              hash = hostHashes.chromium;
            })
            chromiumHeadlessShell
            ffmpegDir
          ];
        };
      };

  # Native shared libs Chromium/WebKit dlopen at runtime when launched via
  # `playwright-cli`. Linux only; Darwin browsers come self-contained.
  browserDeps = lib.optionals stdenv.isLinux [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gobject-introspection
    gtk3
    libdrm
    libgbm
    libpulseaudio
    libxkbcommon
    nspr
    nss
    pango
    systemd
    udev
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

in
buildNpmPackage {
  pname = "playwright-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "v${version}";
    hash = srcHash;
  };

  inherit npmDepsHash;

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = browserDeps;

  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  postFixup = ''
    # Default the bundled Chromium instead of the system "chrome" channel.
    # validateBrowserConfig() in the bundled playwright-core pins
    # channel="chrome" (the /opt/google/chrome/chrome path) when nothing is
    # specified; flipping it to "chromium" makes the CLI use the Chromium
    # shipped here by default. --replace-fail fails the build loudly if a
    # version bump changes this string.
    substituteInPlace \
      $out/lib/node_modules/@playwright/cli/node_modules/playwright-core/lib/coreBundle.js \
      --replace-fail 'browser.launchOptions.channel = "chrome"' \
                     'browser.launchOptions.channel = "chromium"'
  ''
  + lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/playwright-cli \
      ${
        lib.optionalString (browsersDir ? out) "--set-default PLAYWRIGHT_BROWSERS_PATH ${browsersDir.out}"
      } \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath browserDeps}"
  ''
  + lib.optionalString (stdenv.isDarwin && browsersDir ? out) ''
    wrapProgram $out/bin/playwright-cli \
      --set-default PLAYWRIGHT_BROWSERS_PATH ${browsersDir.out}
  '';

  passthru = lib.optionalAttrs (browsersDir ? out) {
    inherit chromiumHeadlessShell;
  };

  meta = {
    description = "Playwright CLI";
    homepage = "https://playwright.dev/";
    license = lib.licenses.mit;
    mainProgram = "playwright-cli";
  };
}

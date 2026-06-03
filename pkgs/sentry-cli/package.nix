{
  lib,
  stdenv,
  system,
  fetchurl,
  gzip,
  patchelf,
  glibc,
  version,
  hash,
}:
let
  platformMap = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };
  platform = platformMap.${system};
  isLinux = stdenv.hostPlatform.isLinux;
in
stdenv.mkDerivation {
  pname = "sentry-cli";
  inherit version;

  # Upstream ships a single prebuilt executable per platform as a bare
  # gzipped binary (no archive wrapper). The Linux builds are Bun-compiled
  # standalone executables (~108MB uncompressed) — the embedded JS bundle is
  # appended after the ELF, and patchelf leaves that payload intact, so a
  # straight --set-interpreter / --set-rpath is enough to run on NixOS. No
  # runtime copy is needed: Bun extracts its embedded modules to $TMPDIR, not
  # next to the binary.
  src = fetchurl {
    url = "https://github.com/getsentry/cli/releases/download/${version}/sentry-${platform}.gz";
    inherit hash;
  };

  nativeBuildInputs = [ gzip ] ++ lib.optionals isLinux [ patchelf ];

  dontConfigure = true;
  dontBuild = true;

  # This is a vendored standalone executable with a Bun bundle appended after
  # the ELF. Let stdenv's fixupPhase nowhere near it: `strip` rewrites the file
  # and drops the trailing payload, and `patchelf --shrink-rpath` (the default
  # patchELF fixup) corrupts the dynamic linking — both surface at runtime as
  # "undefined symbol: , version". The explicit patchelf in installPhase is the
  # only ELF surgery we want.
  dontStrip = true;
  dontPatchELF = true;

  unpackPhase = ''
    runHook preUnpack
    gzip -dc "$src" > sentry
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -D -m0755 sentry "$out/bin/sentry"

    ${lib.optionalString isLinux ''
      patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${
          lib.makeLibraryPath [
            glibc
            stdenv.cc.cc.lib
          ]
        }" \
        "$out/bin/sentry"
    ''}

    runHook postInstall
  '';

  meta = {
    description = "Sentry CLI (getsentry/cli) — the CLI for developers and agents";
    homepage = "https://cli.sentry.dev/";
    downloadPage = "https://github.com/getsentry/cli/releases";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    # FSL-1.1-Apache-2.0: source-available, marked unfree in nixpkgs but
    # redistributable. The flake imports nixpkgs with allowUnfree so the
    # package builds; consumers inherit the already-evaluated derivation.
    license = lib.licenses.fsl11Asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "sentry";
  };
}

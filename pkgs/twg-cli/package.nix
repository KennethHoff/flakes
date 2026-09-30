{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  version,
  hashes,
}:
let
  platform =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
      x86_64-darwin = "darwin-x64";
      aarch64-darwin = "darwin-arm64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "twg-cli: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "twg-cli";
  inherit version;

  src = fetchurl {
    url = "https://teamwork-graph.atlassian.com/cli/twg-${platform}-v${version}";
    hash = hashes.${stdenv.hostPlatform.system} or (throw "twg-cli: no hash for ${stdenv.hostPlatform.system}");
  };

  dontUnpack = true;
  # Bun --compile appends its payload to the binary. strip and the default
  # patchelf fixups (--shrink-rpath, autoPatchelfHook) can corrupt it, so only
  # the explicit --set-interpreter below touches the ELF. Also setting an rpath
  # that includes gcc-lib makes the binary segfault at startup (verified).
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ patchelf ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/twg
    ${lib.optionalString stdenv.isLinux ''
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $out/bin/twg
    ''}
    runHook postInstall
  '';

  meta = {
    description = "Atlassian Teamwork Graph CLI";
    homepage = "https://teamwork-graph.atlassian.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "twg";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}

{
  lib,
  stdenv,
  system,
  fetchurl,
  coreutils,
  glibc,
  icu,
  openssl,
  patchelf,
  runtimeShell,
  version,
  fileVersion ? version,
  hash,
}:
let
  platformMap = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "osx-x64";
    aarch64-darwin = "osx-arm64";
  };
  platform = platformMap.${system};
  isLinux = stdenv.hostPlatform.isLinux;
  isDarwin = stdenv.hostPlatform.isDarwin;
in
stdenv.mkDerivation {
  pname = "aspire-cli";
  inherit version;

  src = fetchurl {
    url = "https://ci.dot.net/public/aspire/${version}/aspire-cli-${platform}-${fileVersion}.tar.gz";
    inherit hash;
  };

  nativeBuildInputs = lib.optionals isLinux [ patchelf ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    tar -xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -D -m0755 aspire "$out/libexec/aspire"

    ${lib.optionalString isLinux ''
      patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --set-rpath "${
          lib.makeLibraryPath [
            glibc
            icu
            openssl
          ]
        }" \
        "$out/libexec/aspire"
    ''}

    mkdir -p "$out/bin"
    wrapper="$out/bin/aspire"
    printf '%s\n' '#!${runtimeShell}' > "$wrapper"
    printf '%s\n' 'set -euo pipefail' >> "$wrapper"
    printf '%s\n' 'state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"' >> "$wrapper"
    printf '%s\n' 'runtime_root="$state_home/aspire-cli/${version}"' >> "$wrapper"
    printf '%s\n' 'runtime_bin="$runtime_root/bin"' >> "$wrapper"
    printf '%s\n' 'runtime_aspire="$runtime_bin/aspire"' >> "$wrapper"
    printf '%s\n' '${coreutils}/bin/mkdir -p "$runtime_bin"' >> "$wrapper"
    printf '%s\n' 'if [ ! -x "$runtime_aspire" ]; then' >> "$wrapper"
    printf '%s\n' '  ${coreutils}/bin/cp "${placeholder "out"}/libexec/aspire" "$runtime_aspire"' >> "$wrapper"
    printf '%s\n' '  ${coreutils}/bin/chmod 755 "$runtime_aspire"' >> "$wrapper"
    printf '%s\n' 'fi' >> "$wrapper"
    ${lib.optionalString isLinux ''
      printf '%s\n' 'export LD_LIBRARY_PATH="${
        lib.makeLibraryPath [
          icu
          openssl
        ]
      }''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' >> "$wrapper"
    ''}
    printf '%s\n' 'exec "$runtime_aspire" "$@"' >> "$wrapper"
    chmod +x "$out/bin/aspire"

    runHook postInstall
  '';

  meta = {
    description = "Aspire CLI";
    homepage = "https://learn.microsoft.com/dotnet/aspire/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "aspire";
  };
}

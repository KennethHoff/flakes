{
  lib,
  buildDotnetModule,
  fetchurl,
  dotnetCorePackages,
  version,
  srcHash,
  nugetDeps,
}:
buildDotnetModule {
  pname = "hex1b";
  inherit version nugetDeps;

  src = fetchurl {
    url = "https://github.com/mitchdenny/hex1b/archive/refs/tags/v${version}.tar.gz";
    hash = srcHash;
  };

  projectFile = "src/Hex1b.Tool/Hex1b.Tool.csproj";
  testProjectFile = "tests/Hex1b.Tool.Tests/Hex1b.Tool.Tests.csproj";
  doCheck = true;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  dotnetBuildFlags = [ "-p:HEX1B_VERSION=${version}" ];
  dotnetTestFlags = [ "-p:HEX1B_VERSION=${version}" ];
  dotnetInstallFlags = [ "-p:HEX1B_VERSION=${version}" ];

  executables = [ "Hex1b.Tool" ];

  postInstall = ''
    ln -s "$out/bin/Hex1b.Tool" "$out/bin/hex1b"
  '';

  meta = {
    description = "hex1b tool for terminal management and diagnostics";
    homepage = "https://hex1b.dev";
    license = lib.licenses.mit;
    platforms = dotnetCorePackages.sdk_10_0.meta.platforms;
    mainProgram = "hex1b";
  };
}

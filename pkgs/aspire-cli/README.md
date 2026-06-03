# Aspire CLI

This is a Nix Flake for the [Aspire](https://aspire.dev) CLI tool.

## Contents

- [Usage](#usage)
- [Use this flake in your project](#use-this-flake-in-your-project)
- [Override the Aspire CLI version](#override-the-aspire-cli-version)
- [Supported platforms](#supported-platforms)
- [Notes](#notes)

## Usage

Run directly from GitHub without cloning:

```bash
nix run github:kennethhoff/flakes#aspire-cli          # stable (default)
nix run github:kennethhoff/flakes#aspire-cli.stable
nix run github:kennethhoff/flakes#aspire-cli.staging
nix run github:kennethhoff/flakes#aspire-cli.dev
```

Run from this repo:

```bash
nix run .#aspire-cli          # or .#aspire-cli.staging, .#aspire-cli.dev
```

Build the package:

```bash
nix build .#aspire-cli
```

## Use this flake in your project

Add this flake as an input and include the package in your dev shell.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flakes.url = "github:kennethhoff/flakes";
  };

  outputs = {
    self,
    nixpkgs,
    flakes,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        flakes.packages.${system}.aspire-cli
        # stable; or pick a channel: aspire-cli.staging, aspire-cli.dev
      ];
    };
  };
}
```

Then run `nix develop` and use `aspire`.

## Override the Aspire CLI version

The package is parameterized by `version`, `fileVersion`, and `hash`.

If you want to use a different Aspire CLI version, override these values:

```nix
let
  aspire = flakes.packages.${system}.aspire-cli.override {
    version = "<aspire-version>";
    fileVersion = "<file-version>"; # defaults to version if omitted
    hash = "<nix-hash>";
  };
in {
  devShells.${system}.default = pkgs.mkShell {
    packages = [aspire];
  };
}
```

To get the correct `hash` for a new version, run a build once and copy the `got: ...` hash from the failure message.

The version string includes a `-**` qualifier (for example `-preview...`), so be sure to use the full version from the upstream tarball URL:
`https://ci.dot.net/public/aspire/<version>/aspire-cli-linux-x64-<version>.tar.gz`.

You can resolve the latest version for each channel by following redirects:

```bash
# stable
curl -sL -o /dev/null -w '%{url_effective}\n' https://aka.ms/dotnet/9/aspire/ga/daily/aspire-cli-linux-x64.tar.gz \
  | sed -n 's#^.*/public/aspire/\([^/]*\)/.*#\1#p'

# staging
curl -sL -o /dev/null -w '%{url_effective}\n' https://aka.ms/dotnet/9/aspire/rc/daily/aspire-cli-linux-x64.tar.gz \
  | sed -n 's#^.*/public/aspire/\([^/]*\)/.*#\1#p'

# dev
curl -sL -o /dev/null -w '%{url_effective}\n' https://aka.ms/dotnet/9/aspire/daily/aspire-cli-linux-x64.tar.gz \
  | sed -n 's#^.*/public/aspire/\([^/]*\)/.*#\1#p'
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## Notes

- Versions are updated weekly via GitHub Actions.

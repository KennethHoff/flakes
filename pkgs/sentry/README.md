# Sentry CLI

This is a Nix Flake for the [Sentry](https://cli.sentry.dev) CLI tool ([`getsentry/cli`](https://github.com/getsentry/cli)).

This is the new "CLI for developers and agents" (`sentry`), not the older
build/release plumbing tool (`sentry-cli` / `@sentry/cli`). It can query and
manage issues, events, releases, projects, and more — for example:

```bash
sentry auth login
sentry issue list my-org/frontend --query "is:unresolved" --sort freq
sentry issue view @latest
```

## Contents

- [Usage](#usage)
- [Use this flake in your project](#use-this-flake-in-your-project)
- [Override the Sentry CLI version](#override-the-sentry-cli-version)
- [Supported platforms](#supported-platforms)
- [Updating](#updating)
- [Notes](#notes)

## Usage

Run directly from GitHub without cloning:

```bash
nix run github:kennethhoff/flakes#sentry-cli
```

Run from this repo:

```bash
nix run .#sentry-cli
```

Build the package:

```bash
nix build .#sentry-cli
```

Add to a temporary shell:

```bash
nix shell .#sentry-cli --command sentry --help
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
        flakes.packages.${system}.sentry-cli
      ];
    };
  };
}
```

Then run `nix develop` and use `sentry`.

The Sentry CLI is licensed under FSL-1.1-Apache-2.0, which nixpkgs marks as
unfree (but redistributable). This flake builds it with `allowUnfree` enabled,
and the resulting derivation is already evaluated — so you do **not** need to
set `allowUnfree` in your own config to consume it.

## Override the Sentry CLI version

The package is parameterized by `version` and `hash`.

If you want to use a different Sentry CLI version, override these values:

```nix
let
  sentry = flakes.packages.${system}.sentry-cli.override {
    version = "<sentry-version>";
    hash = "<nix-hash>"; # sha256 of sentry-<platform>.gz for this system
  };
in {
  devShells.${system}.default = pkgs.mkShell {
    packages = [sentry];
  };
}
```

To get the correct `hash` for a new version, run a build once and copy the
`got: ...` hash from the failure message, or prefetch it directly:

```bash
nix store prefetch-file --json \
  https://github.com/getsentry/cli/releases/download/<version>/sentry-linux-x64.gz \
  | jq -r .hash
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

(Upstream also ships `windows-x64` and Linux `musl` builds; those are not
exposed by this flake.)

## Updating

To bump to the latest release, run:

```bash
nix run .#update-sentry
```

This fetches the latest release tag from GitHub, prefetches the per-platform
binary hashes, and rewrites `versions.nix`.

## Notes

- The Linux builds are Bun-compiled standalone executables. They are patched
  with `patchelf` (interpreter + rpath) so they run on NixOS; the appended JS
  bundle is left untouched.
- Versions are updated weekly via GitHub Actions.

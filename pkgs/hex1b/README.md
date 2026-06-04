# hex1b

This package builds [hex1b](https://github.com/mitchdenny/hex1b) (`hex1b`) from source using .NET.

## Usage

Run directly from GitHub without cloning:

```bash
nix run github:kennethhoff/flakes#hex1b
```

Run from this repo:

```bash
nix run .#hex1b
```

Build the package:

```bash
nix build .#hex1b
```

## Supported platforms

The package follows the platforms supported by `dotnetCorePackages.sdk_10_0` in nixpkgs.

## Updating

To bump to the latest release and regenerate source/dependency hashes, run:

```bash
nix run .#update-hex1b
```

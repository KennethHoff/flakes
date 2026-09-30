# Teamwork Graph CLI

This is a Nix Flake for the [Atlassian Teamwork Graph](https://teamwork-graph.atlassian.com/) CLI (`twg`). It repackages the prebuilt upstream binaries.

## Usage

```bash
nix run github:kennethhoff/flakes#twg-cli -- -v
nix run .#twg-cli -- --help
nix build .#twg-cli
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`


## Updating

```bash
nix run .#update-twg-cli
```

This scrapes `DEFAULT_VERSION` from the upstream install script and rewrites `versions.nix` using upstream's `SHA256SUMS`.

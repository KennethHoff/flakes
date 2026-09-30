# flakes

Personal Nix flakes in one repo. Each CLI lives in its own `pkgs/<name>/`
directory, and the root `flake.nix` finds them on its own. Adding a package
means adding a directory. The root flake only changes when a tool needs an
extra flake input.

## Packages

| Package | Tool | Directory |
| --- | --- | --- |
| `cve-lite-cli` | [OWASP CVE Lite CLI](https://github.com/OWASP/cve-lite-cli) | [`pkgs/cve-lite-cli`](pkgs/cve-lite-cli) |
| `playwright-cli` | [Playwright CLI](https://playwright.dev) | [`pkgs/playwright-cli`](pkgs/playwright-cli) |
| `sentry-cli` | [Sentry CLI](https://cli.sentry.dev) | [`pkgs/sentry-cli`](pkgs/sentry-cli) |
| `twg-cli` | [Atlassian Teamwork Graph CLI](https://developer.atlassian.com/cloud/twg-cli/) | [`pkgs/twg-cli`](pkgs/twg-cli) |

There is no `default` package or app, so always name the output, as in
`#sentry-cli`. `nix run .#<name>` runs the package's `meta.mainProgram`, so no
tool needs its own run app.

## Usage

```bash
# Run a CLI without cloning:
nix run github:kennethhoff/flakes#playwright-cli
nix run github:kennethhoff/flakes#sentry-cli
nix run github:kennethhoff/flakes#twg-cli

# Build a package:
nix build github:kennethhoff/flakes#sentry-cli

# Dev shell with every CLI on PATH:
nix develop github:kennethhoff/flakes
```

To use a package from another flake:

```nix
{
  inputs.flakes.url = "github:kennethhoff/flakes";
  outputs = { self, nixpkgs, flakes, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        flakes.packages.${system}.sentry-cli
        flakes.packages.${system}.twg-cli
      ];
    };
  };
}
```

Each tool's README, linked from the table, covers its usage, version
overrides, and platform notes.

## Adding a package

1. Create `pkgs/<name>/` with the packaging files: `package.nix`,
   `versions.nix`, `update.sh`, `README.md`, and optionally `tests/`.
2. Add `pkgs/<name>/default.nix`. It returns an attribute set, and every key is
   optional:

   ```nix
   { inputs, system, self, lib }:
   let
     pkgs = inputs.nixpkgs.legacyPackages.${system}; # or import with overlays/config
     # drv = pkgs.callPackage ./package.nix { ... };  # must set meta.mainProgram
   in {
     packages = { <name> = drv; };                              # globally-unique name
     # No run-app needed: `nix run .#<name>` resolves the package and runs its
     # meta.mainProgram. Declare an updater spec and the root builds the
     # `update-<name>` app for you (adds git + a cd into this dir):
     update = { runtimeInputs = [ /* curl, jq, nix, … */ ]; script = ./update.sh; };
     checks = import ./tests { inherit pkgs self; };            # may be {}
     devShellPackages = [ drv ];                                 # added to the shared dev shell
   }
   ```

The root flake adds the new tool to `packages`, `apps`, `checks`, and
`devShells`. The weekly update workflow picks it up through its `update-<name>`
app.

### Rules every tool follows

- **The directory name is the package name.** `pkgs/<name>/` produces the
  package `<name>`, the `update-<name>` app, and checks named `<name>-*`. It is
  also the Conventional Commit scope the update workflow uses.
- **Set `meta.mainProgram` on each package.** Without it, `nix run .#<name>`
  doesn't know which binary to start.
- **Declare an `update` spec** of `{ runtimeInputs; script; }`. The root wraps
  it as the `update-<name>` app, which adds `git` and changes into the tool's
  directory before running the script. `update.sh` only has to write
  `versions.nix` to the current directory, and the app works from anywhere in
  the repo.
- **Return bare check names** from `tests/default.nix`. The root adds the
  `<name>-` prefix.
- **Keep one derivation per package.** Merging derivations, as in
  `a // { b = …; }`, puts the extra derivations on consumers' dev shell PATH.

## Updating versions

Each tool's `update-<name>` app bumps its `versions.nix`:

```bash
nix run .#update-sentry-cli
```

Every week, `.github/workflows/update.yml` runs each tool's updater. When a new
upstream version lands, it opens one auto-merging PR for that tool.

## Caveats

- **There is one `flake.lock`.** `nix flake update` bumps `nixpkgs` for every
  tool at once, and no tool can pin its own nixpkgs. That's fine for personal
  use.
- **The old per-tool repos still work.** Consumers pinned to
  `github:kennethhoff/<tool>-cli-flake` don't need to move.

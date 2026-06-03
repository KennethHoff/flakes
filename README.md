# flakes

A monorepo of personal Nix flakes. Each packaged CLI lives in its own
`pkgs/<name>/` directory; the root `flake.nix` auto-discovers them, so adding a
new package is "drop a directory" — no edits to the root flake (unless the tool
needs an extra pinned input).

## Packages

| Package | Tool | Directory |
| --- | --- | --- |
| `aspire-cli` (+ `.stable`/`.staging`/`.dev`) | [Aspire CLI](https://aspire.dev) | [`pkgs/aspire-cli`](pkgs/aspire-cli) |
| `playwright-cli` | [Playwright CLI](https://playwright.dev) | [`pkgs/playwright-cli`](pkgs/playwright-cli) |
| `sentry-cli` | [Sentry CLI](https://cli.sentry.dev) | [`pkgs/sentry-cli`](pkgs/sentry-cli) |

There is **no** `default` package or app — a multi-tool repo has no single
obvious default, so name the output explicitly (`#aspire-cli`, `#sentry-cli`, …).
The CLIs have no dedicated run-app: `nix run .#<name>` resolves the package and
runs its `meta.mainProgram`. aspire's channels hang off the package as sub-attrs,
so `#aspire-cli.staging` runs that channel.

## Usage

```bash
# Run a CLI without cloning:
nix run github:kennethhoff/flakes#aspire-cli          # or .#aspire-cli.staging / .dev
nix run github:kennethhoff/flakes#playwright-cli
nix run github:kennethhoff/flakes#sentry-cli

# Build a package:
nix build github:kennethhoff/flakes#sentry-cli

# Dev shell with every CLI on PATH:
nix develop github:kennethhoff/flakes
```

Consume in your own flake:

```nix
{
  inputs.flakes.url = "github:kennethhoff/flakes";
  outputs = { self, nixpkgs, flakes, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [ flakes.packages.${system}.sentry-cli ];
    };
  };
}
```

Per-package usage, version-override, and platform notes live in each tool's
README (linked in the table above).

## Adding a package

1. Create `pkgs/<name>/` (named after the package) and add the packaging files
   (`package.nix`, `versions.nix`, `update.sh`, `README.md`, optional `tests/`).
2. Add `pkgs/<name>/default.nix` returning the tool-module contract — every key
   is optional:

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

   The **directory name is the canonical name**: `pkgs/<name>/` gives package
   `<name>`, the `update-<name>` app, checks `<name>-*`, and the Conventional
   Commit scope the workflow uses — so name the dir after the package
   (`aspire-cli`, `sentry-cli`, …). Channels/variants can hang off a package as
   sub-attrs (`aspire-cli.staging`), runnable via the same mainProgram fallback.

That's it. The root flake folds the new tool into `packages`/`apps`/`checks`/
`devShells`, and the weekly update workflow auto-discovers it via its
`update-<name>` app. The only reason to touch the root `flake.nix` is when a
tool needs an extra **flake input** (Nix requires inputs at the root) — see the
`nixpkgs-openssl` pin that `pkgs/aspire-cli` consumes.

### Conventions a tool must follow

- **Dir name = package name** — name `pkgs/<name>/` after its package. That name
  is the output name, the `update-<name>` app, the `<name>-*` check prefix, and
  the Conventional Commit scope the workflow uses.
- **`meta.mainProgram`** — set it on each package so `nix run .#<name>` works
  without a dedicated run-app.
- **`update` spec** — declare `{ runtimeInputs; script; }` and the root builds
  the `update-<dir>` app: it adds `git`, cd's into the tool's dir (resolved from
  the repo root), then runs the script — so `nix run .#update-<dir>` works from
  anywhere. `update.sh` just writes `versions.nix` to the current directory.
- **Namespaced checks** — `tests/default.nix` returns bare keys; the root
  prefixes them with `<name>-`.

## Updating versions

Each tool ships an `update-<name>` app that bumps its `versions.nix`. Run it
from anywhere in the repo:

```bash
nix run .#update-sentry-cli
```

The `.github/workflows/update.yml` matrix runs every tool's updater weekly,
opening one auto-merging PR per tool when a new upstream version lands.

## Caveats

- **One `flake.lock`.** `nix flake update` bumps `nixpkgs` for every tool at
  once; a tool's nixpkgs can't be pinned independently. Fine for personal use.
- **`nixpkgs-openssl` pin.** Temporary OpenSSL 3.6.1 pin for the Aspire CLI;
  carries a `TODO(~2026-07)` to revisit — see `pkgs/aspire-cli/default.nix`.
- **Old per-tool repos stay live.** This migration is additive; existing
  consumers pinned to `github:kennethhoff/<tool>-cli-flake` keep working.

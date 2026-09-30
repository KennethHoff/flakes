---
name: flakes-add-package
description: Add a new CLI package to this flakes monorepo. USE WHEN the user says "add a package", "package <tool> in the flakes repo", "install <CLI> here", "add <tool> to flakes", or pastes a vendor install URL or install script for a CLI. DO NOT USE FOR bumping an existing tool's version (run `nix run .#update-<name>`) or for changing the root flake.
---

# Add a package to flakes

The contract and conventions live in the repo docs. Read them first, do not work from memory:

- `README.md`, sections "Adding a package" and "Rules every tool follows".
- `AGENTS.md`, sections "Nix gotchas" (stage new files), "Repository shape", and "Commit Convention".

## Steps

1. Copy the closest package under `pkgs/`. For a vendor's prebuilt binary, read [references/nix-prebuilt-binary.md](references/nix-prebuilt-binary.md) first; `pkgs/twg-cli` and `pkgs/sentry-cli` are prebuilt Bun binaries. Never run the vendor's `curl | bash` installer.
2. Name the directory `pkgs/<name>`. The name is the package, the `update-<name>` app, the check prefix, and the commit scope.
3. Add the tool everywhere the repo lists tools:
   - a row in the README "Packages" table
   - the README "Usage" examples
   - the README consume-in-your-flake example
   - the example list in `.github/workflows/update.yml`

   The twg-cli addition missed the README on the first pass.
4. Write tests in `pkgs/<name>/tests/`, planned with the `testing` skill. `pkgs/twg-cli/tests/` is the template: exact version, help output with the tool's own marker, version override, src URL per system (eval only), exact platforms, unsupported-system throw, and an offline `update.sh` test against fixtures.
5. Stage new files with `git add --intent-to-add`.

## Verify

- `nix build .#<name>`
- `nix flake check`
- `nix run .#update-<name>`, which must change nothing when already at the latest version.

Commit as `feat(<name>): add <description>`.

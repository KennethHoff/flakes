# Agents Guide

## Repository shape

Monorepo of Nix flakes. One package per `pkgs/<name>/` directory; the root
`flake.nix` auto-discovers them. To add a package, drop a `pkgs/<name>/` with a
`default.nix` returning the tool-module contract — see [README.md](README.md),
section "Adding a package". Avoid editing the root `flake.nix` unless a tool
needs an extra **flake input** (those must be declared at the root).

Tool conventions (enforced by convention, not code):
- The directory name is the package name: `pkgs/<name>/` → package `<name>`,
  the `update-<name>` app, `<name>-*` checks, and the commit scope.
- An `update` spec `{ runtimeInputs; script; }`; the root builds the
  `update-<name>` app (adds git + a cd into the tool's dir, resolved from the
  repo root). `update.sh` writes `versions.nix` to the current directory.
- `tests/default.nix` returns bare keys; the root namespaces them as `<name>-<check>`.

## Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

Format: `<type>: <description>`

Common types:
- `feat` – new feature
- `fix` – bug fix
- `chore` – maintenance, dependency updates, tooling
- `docs` – documentation only
- `refactor` – code restructuring without behavior change
- `ci` – CI/CD pipeline changes
- `test` – adding or updating tests
- `style` – formatting, whitespace

When a change is scoped to one tool, use its **directory name** as the scope —
which is the package name, e.g. `sentry-cli`. The auto-update workflow uses the
same scope.

Examples:
```
feat(playwright-cli): add support for all major Nix platforms
fix(sentry-cli): pin openssl 3.6.1 for DCP TLS handshake
chore(cve-lite-cli): update CLI to 0.8.2
docs: document the add-a-package contract
ci: matrix the weekly auto-update workflow over all tools
```

Keep the description lowercase and concise. No period at the end.

When the change is non-trivial, add a body to summarize what changed and why.
Separate it from the subject with a blank line.

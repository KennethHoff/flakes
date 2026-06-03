# Agents Guide

## Repository shape

Monorepo of Nix flakes. One packaged CLI per `pkgs/<tool>/` directory; the root
`flake.nix` auto-discovers them. To add a package, drop a `pkgs/<tool>/` with a
`default.nix` returning the tool-module contract — see [README.md](README.md),
section "Adding a package". Avoid editing the root `flake.nix` unless a tool
needs an extra **flake input** (those must be declared at the root).

Tool conventions (enforced by convention, not code):
- Unique output names — packages/apps share one namespace across tools.
- Each tool declares its primary package `name` in `default.nix` (the commit
  scope; surfaced repo-wide as `lib.packageNames`).
- An `update` spec `{ runtimeInputs; script; }`; the root builds the
  `update-<tool>` app (adds git + a cd into the tool's dir, resolved from the
  repo root). `update.sh` writes `versions.nix` to the current directory.
- `tests/default.nix` returns bare keys; the root namespaces them as `<tool>-<check>`.

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

When a change is scoped to one tool, use that tool's **package name** as the
scope (the `name` it declares in `default.nix` — `aspire-cli`, not `aspire`).
The auto-update workflow uses the same scope, read from `lib.packageNames`.

Examples:
```
feat(playwright-cli): add support for all major Nix platforms
fix(aspire-cli): pin openssl 3.6.1 for DCP TLS handshake
chore(sentry-cli): update CLI to 0.35.0
docs: document the add-a-package contract
ci: matrix the weekly auto-update workflow over all tools
```

Keep the description lowercase and concise. No period at the end.

When the change is non-trivial, add a body to summarize what changed and why.
Separate it from the subject with a blank line.

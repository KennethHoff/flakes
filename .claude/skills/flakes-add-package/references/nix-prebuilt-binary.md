# Nix prebuilt binary

Package release binaries per system, and keep the pins fresh with a script. These gotchas all came from packaging twg-cli, a Bun `--compile` binary.

## Find the facts without running the installer

The vendor install script usually shows the URL scheme, the checksum file name, and how to query the latest version. Read it. Do not run it: installers edit shell profiles, send telemetry, and prompt for login.

## Hashes

Take hashes from the vendor's checksum file and convert with `nix hash convert --to sri`. One small download replaces fetching every binary.

## Bun `--compile` binaries

Bun appends a payload to the executable. Anything that rewrites the ELF corrupts it.

- Set `dontStrip = true` and `dontPatchELF = true`. Skip `autoPatchelfHook`.
- Set only the interpreter with `patchelf --set-interpreter`. Adding an rpath made twg-cli segfault.
- A corrupted binary behaves as plain `bun`, and Bun's own version can equal the tool's. Check the tool's own `--help` text, not just `-v`.

## Unsupported systems

Write `or (throw "unsupported system: ${system}")` on both the URL-mapping lookup and the hash lookup. A bare missing attribute error is not catchable, so `builtins.tryEval` can't test the failure. In a test, `tryEval` only `src.url`, because forcing the whole derivation can fail for unrelated reasons.

## Update scripts

A failing `$(...)` inside a heredoc does not trip `set -e`. The twg-cli updater wrote an empty value and exited 0. Assign each value to a variable first (`set -e` fires on a plain assignment), check it is non-empty, then write the file from the variables.

Let an environment variable override the vendor base URL, so the script can run offline against fixture files.

## Metadata

Set `meta.sourceProvenance = [ lib.sourceTypes.binaryNativeCode ]` so the package is marked as a binary. Set `meta.mainProgram` so `nix run` knows what to start.

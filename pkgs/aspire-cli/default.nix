# Per-tool module. The root flake auto-discovers this directory and folds the
# returned attrset into the flake outputs. Contract (all keys optional):
#   { packages, apps, checks, devShellPackages }
{
  inputs,
  system,
  self,
  lib,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # Workaround for the Aspire CLI's DCP TLS handshake failing under OpenSSL
  # 3.6.2 on Linux. `aspire run` trusts a self-signed localhost dev cert for
  # the AppHost<->DCP control-plane connection; under 3.6.2 the AppHost
  # crashes on startup with "SSL connection could not be established /
  # unexpected EOF" (the "PartiallyFailedToTrustTheCertificate" line on
  # NixOS is benign — it shows up on 3.6.1 too). OpenSSL 3.6.1 works.
  #
  # This was isolated by bisection: holding everything else at current
  # (aspire-cli 13.3.x, dotnet-sdk 10.0.300, nixpkgs nixos-unstable) and
  # flipping ONLY the openssl this CLI links flips boot<->crash. The CLI
  # loads openssl via this package's RPATH/LD_LIBRARY_PATH (see package.nix),
  # so feeding the pinned openssl in as the package's `openssl` argument fixes
  # the CLI without touching the consumer's nixpkgs. (An overlay would also
  # work but perturbs the whole package set's stdenv bootstrap — overriding
  # just this one callPackage argument is surgical and cross-eval-safe.)
  #
  # NOTE: this is NOT microsoft/aspire#13219 (SSL_CERT_DIR not propagated) —
  # that was fixed by PR #13221 in the Aspire 13.1 milestone, and the CLI
  # versions shipped here (>=13.1) already include it. The root cause is an
  # OpenSSL 3.6.1->3.6.2 cert/TLS-verification behaviour change; the exact
  # upstream change has not been pinned down yet.
  #
  # TODO(~2026-07): revisit this pin (added 2026-05-31). Re-test by dropping
  # `nixpkgs-openssl` + this override and `aspire run`-ing an AppHost on Linux
  # — if a newer OpenSSL (>3.6.2) or Aspire CLI boots cleanly, delete the
  # input and override. If still broken, narrow the OpenSSL change (diff
  # 3.6.1..3.6.2 CHANGES.md) and file an upstream issue. Don't let this pin
  # rot — it freezes the CLI's OpenSSL and misses its security updates.
  pinnedOpenssl = inputs.nixpkgs-openssl.legacyPackages.${system}.openssl;

  versions = import ./versions.nix;

  mkAspire =
    channel:
    pkgs.callPackage ./package.nix {
      inherit system;
      openssl = pinnedOpenssl;
      inherit (versions.${channel}) version fileVersion;
      hash = versions.${channel}.hashes.${system};
    };

  stable = mkAspire "stable";
  staging = mkAspire "staging";
  dev = mkAspire "dev";
in
{
  packages = {
    # `nix build .#aspire-cli` builds stable; the channels hang off it as
    # sub-attrs, so `.#aspire-cli.stable` / `.staging` / `.dev` build a
    # specific one. (aspire-cli is the stable derivation carrying its siblings.)
    aspire-cli = stable // {
      inherit stable staging dev;
    };
  };

  # `nix run .#aspire-cli` (and `.#aspire-cli.staging` / `.dev`) resolves the
  # package and runs its meta.mainProgram — no run-app needed. The root flake
  # turns the `update` spec below into the `update-aspire-cli` app (adds git +
  # a cd into this dir, so it works from anywhere in the repo).
  update = {
    runtimeInputs = [
      pkgs.cacert
      pkgs.coreutils
      pkgs.curl
      pkgs.findutils
      pkgs.gnused
      pkgs.nix
    ];
    script = ./update.sh;
  };

  checks = import ./tests { inherit pkgs self; };

  devShellPackages = [ stable ];
}

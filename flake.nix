{
  description = "Monorepo of personal Nix flakes — one package per pkgs/<name>/ directory";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Consumed only by pkgs/aspire-cli (OpenSSL 3.6.1 pin — see its default.nix).
    # Inputs must live at the flake root, so a tool needing an extra pinned
    # input adds a line here; ordinary tools need nothing but nixpkgs.
    nixpkgs-openssl.url = "github:NixOS/nixpkgs/549bd84d6279f9852cae6225e372cc67fb91a4c1";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = f: lib.genAttrs systems f;

      # Auto-discovery: every subdirectory of ./pkgs is a tool. Adding a CLI is
      # "drop a pkgs/<name>/default.nix" — no edit to this file (unless the tool
      # needs an extra flake input, which must be declared above).
      toolNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./pkgs)
      );

      # Evaluate each tool module once per system. Each returns an attrset with
      # any of { packages, apps, checks, devShellPackages }.
      toolOutputs = forAllSystems (
        system:
        lib.genAttrs toolNames (
          name:
          import (./pkgs + "/${name}") {
            inherit
              inputs
              system
              self
              lib
              ;
          }
        )
      );

      # Merge attr `field` from every tool for a system. `transform` rewrites
      # each tool's sub-attrset before merging (used to namespace checks).
      mergeField =
        system: field: transform:
        lib.foldl' (
          acc: name: acc // transform name (toolOutputs.${system}.${name}.${field} or { })
        ) { } toolNames;

      id = _: x: x;

      # Build a tool's `update-<dir>` app from its declared `update` spec. git
      # and the cd into the tool's dir (resolved from the repo root) are added
      # here, so no tool reimplements them and `nix run .#update-<dir>` works
      # from anywhere in the repo.
      mkUpdateApp = dir: pkgs: update: {
        type = "app";
        program = lib.getExe (
          pkgs.writeShellApplication {
            name = "${dir}-flake-update";
            runtimeInputs = [ pkgs.git ] ++ (update.runtimeInputs or [ ]);
            text = ''
              cd "$(git rev-parse --show-toplevel)/pkgs/${dir}"
            ''
            + builtins.readFile update.script;
          }
        );
      };
    in
    {
      # Flat, globally-unique names (aspire-cli, sentry-cli, playwright-cli, …).
      # No `default` — a multi-tool repo has no single obvious default; name the
      # package or app explicitly.
      packages = forAllSystems (system: mergeField system "packages" id);

      # Each tool's own apps (if any) plus an auto-generated `update-<dir>` app
      # for every tool that declares an `update` spec.
      apps = forAllSystems (
        system:
        let
          basePkgs = nixpkgs.legacyPackages.${system};
          appsFor =
            name:
            let
              t = toolOutputs.${system}.${name};
            in
            (t.apps or { })
            // (lib.optionalAttrs (t ? update) {
              "update-${name}" = mkUpdateApp name basePkgs t.update;
            });
        in
        lib.foldl' (acc: name: acc // appsFor name) { } toolNames
      );

      # Namespaced per tool (aspire-readme, sentry-smoke, …) to avoid collisions.
      checks = forAllSystems (
        system:
        mergeField system "checks" (
          name: checks: lib.mapAttrs' (k: v: lib.nameValuePair "${name}-${k}" v) checks
        )
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          packages = lib.concatMap (name: toolOutputs.${system}.${name}.devShellPackages or [ ]) toolNames;
        in
        {
          default = pkgs.mkShell { inherit packages; };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}

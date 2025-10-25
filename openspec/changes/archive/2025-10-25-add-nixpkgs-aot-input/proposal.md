# Add nixpkgs-aot Input

## Why

Sometimes `nixpkgs-unstable` has build failures that prevent full system upgrades. However, many packages build successfully and would be useful to access without waiting for all issues to be resolved. A separate `nixpkgs-aot` (ahead-of-time) input allows pulling specific packages from a newer nixpkgs version while keeping the main system on a stable base.

## What Changes

- Add `nixpkgs-aot` flake input pointing to the same `nixos-unstable` branch as `nixpkgs`
- Make `nixpkgs-aot` packages accessible via separate `pkgs-aot` parameter (completely isolated from `pkgs`)
- Allow independent updates: sometimes both inputs will be updated together, sometimes only `nixpkgs-aot` will advance
- No changes to existing `pkgs` parameter (fully isolated)

## Impact

- Affected specs: `nix-flake-config` (new capability)
- Affected code: `flake.nix` (add input and `pkgs-aot` parameter)
- User benefit: Access to latest package versions without full system upgrade, complete isolation from main `pkgs`
- Risk: Minimal - separate parameters prevent conflicts, packages from newer nixpkgs typically work with older system

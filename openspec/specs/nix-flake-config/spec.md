# nix-flake-config Specification

## Purpose
TBD - created by archiving change add-nixpkgs-aot-input. Update Purpose after archive.
## Requirements
### Requirement: Ahead-of-Time nixpkgs Input

The flake SHALL provide a separate `nixpkgs-aot` input that points to `github:NixOS/nixpkgs/nixos-unstable` and can be updated independently from the main `nixpkgs` input.

#### Scenario: Access newer package version

- **GIVEN** the main `nixpkgs` input is locked to an older commit due to build issues
- **AND** `nixpkgs-aot` is updated to a newer commit
- **WHEN** referencing a package via `pkgs-aot.<package-name>`
- **THEN** the package from the `nixpkgs-aot` input is used

#### Scenario: Independent input updates

- **GIVEN** both `nixpkgs` and `nixpkgs-aot` inputs exist
- **WHEN** running `nix flake update nixpkgs-aot`
- **THEN** only `nixpkgs-aot` is updated while `nixpkgs` remains at its current commit

#### Scenario: Synchronized updates

- **GIVEN** both `nixpkgs` and `nixpkgs-aot` inputs exist
- **WHEN** running `nix flake update` without specifying inputs
- **THEN** both `nixpkgs` and `nixpkgs-aot` are updated to their latest commits

### Requirement: Ahead-of-Time Package Access

All packages from `nixpkgs-aot` SHALL be accessible through a separate `pkgs-aot` parameter passed to all modules.

#### Scenario: Package access in NixOS modules

- **GIVEN** a NixOS module with `pkgs-aot` in its arguments
- **WHEN** referencing `pkgs-aot.somePackage`
- **THEN** the package from `nixpkgs-aot` input is available

#### Scenario: Package access in Home Manager modules

- **GIVEN** a Home Manager module with `pkgs-aot` in its arguments
- **WHEN** referencing `pkgs-aot.somePackage`
- **THEN** the package from `nixpkgs-aot` input is available

#### Scenario: Package access in nix-darwin modules

- **GIVEN** a nix-darwin module with `pkgs-aot` in its arguments
- **WHEN** referencing `pkgs-aot.somePackage`
- **THEN** the package from `nixpkgs-aot` input is available

### Requirement: Consistent Package Behavior

Packages from `nixpkgs-aot` SHALL maintain the same configuration options as the main `nixpkgs` (such as `allowUnfree`).

#### Scenario: Unfree packages available in aot

- **GIVEN** `allowUnfree` is configured for the main nixpkgs
- **WHEN** accessing an unfree package via `pkgs-aot.<unfree-package>`
- **THEN** the unfree package is available without additional configuration


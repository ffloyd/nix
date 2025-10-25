# Implementation Tasks

## 1. Add nixpkgs-aot Input

- [x] 1.1 Add `nixpkgs-aot` input to flake inputs pointing to `github:NixOS/nixpkgs/nixos-unstable`
- [x] 1.2 Verify input appears in `flake.lock` after running `nix flake lock`

## 2. Implement AOT Package Access

- [x] 2.1 Create `pkgs-aot` package set for x86_64-linux by importing `nixpkgs-aot`
- [x] 2.2 Create `pkgs-aot` package set for aarch64-darwin by importing `nixpkgs-aot`
- [x] 2.3 Configure both `pkgs-aot` instances with same config as main nixpkgs (allowUnfree)
- [x] 2.4 Add `pkgs-aot` to `commonContext` alongside other shared values
- [x] 2.5 Verify it's automatically available in NixOS, Home Manager, and nix-darwin modules

## 3. Testing and Validation

- [x] 3.1 Test package access in NixOS module using `pkgs-aot.<package>`
- [x] 3.2 Test package access in Home Manager module using `pkgs-aot.<package>`
- [x] 3.3 Test independent input updates with `nix flake update nixpkgs-aot`
- [x] 3.4 Verify both inputs update together with `nix flake update`
- [x] 3.5 Run `nix flake check` to ensure flake validity

## 4. Documentation

- [x] 4.1 Update README.md to document `nixpkgs-aot` usage pattern
- [x] 4.2 Add example of using `pkgs-aot.<package>` in configuration
- [x] 4.3 Document module signature pattern: `{ pkgs, pkgs-aot, ... }:`

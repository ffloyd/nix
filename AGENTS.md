# Agent Guide

## Build/Test Commands (NixOS)
- Format: `nix fmt`
- Lint: `statix check` (repeated_keys disabled)
- Validate flake: `nix flake check`
- Test build: `nixos-rebuild dry-build --flake .`
- Test activation: `nixos-rebuild dry-activate --flake .`

**IMPORTANT**: Never apply configurations to the system. Always let the user run `nixos apply` (or alias `os-rebuild`) manually.

See @README.md for detailed common tasks documentation.

## Code Style
- Language: Nix configuration files
- Use objective-based organization: modules named after goals/objectives, not technical categories
- Comments explain "why" not "what"
- Use inline sub-modules in `imports` for feature isolation (Nix forbids duplicate keys)
- Never perform git staging/commits unless explicitly asked
- Always update documentation after code changes

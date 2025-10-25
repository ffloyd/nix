<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Agent Guide

## Build/Test Commands (NixOS)
- Format: `nix fmt .`
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

## Module Parameters

All modules receive these parameters via `specialArgs`/`extraSpecialArgs`:

**Common context:**
- `inputs` - Flake inputs
- `globals` - Global configuration values from `globals.nix`
- `private` - Encrypted private data from `private.nix`
- `mkDotfilesLink` - Helper for creating out-of-store symlinks
- `mkDotfilesDirectoryEntriesSymlinks` - Helper for directory symlinks
- `mkEnvExports` - Helper for shell export statements

**Per-system context:**
- `username` - User name from private data
- `hostname` - Host name from private data
- `targetOS` - Either "nixos" or "macos"
- `pkgs-aot` - Ahead-of-time nixpkgs for accessing newer packages

**Standard Nix parameters:**
- `pkgs` - Main nixpkgs instance
- `config` - Current system/home configuration
- `lib` - nixpkgs library functions

## AI Assistant Configuration

This project uses a three-tier system for sharing AI assistant configurations:

1. **Shared "as is"** (`dotfiles/ai-shared/`): Content identical between tools → symlinked directly (editable)
2. **Shared snippets** (`hm/development-environment/ai-tooling/`): Content with tool-specific frontmatter → Nix-generated (immutable)
3. **Tool-specific** (`dotfiles/claude/`, `dotfiles/opencode/`): Tool configs, experimental commands/agents → symlinked directly (editable)

See `@/openspec/project.md` for architecture rationale and design decisions.

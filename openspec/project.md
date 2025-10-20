# Project Context

## Purpose

Personal system configurations achieving reproducible, declarative system management across NixOS and macOS. The intent is to maintain consistent development environments while respecting platform differences.

## Core Architecture

The `flake.nix` defines per-host system configurations by composing modules from different directories.

### Entry Point

**`flake.nix`** - Orchestrates system configurations for each host
- Defines `nixosSystem()` and `macosSystem()` builder functions
- For each host, specifies which modules to include
- Passes shared context (globals, private data, helpers) to all modules
- Outputs: `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`

### Module Collections

Modules are organized by scope and pulled in by host configurations:

**`nixos/`** - NixOS system-level modules
- System services, desktop environment, hardware drivers
- Examples: `base.nix`, `desktop.nix`, `browser.nix`, `gaming.nix`

**`darwin/`** - macOS system-level modules
- System preferences and Homebrew casks
- Limited scope due to macOS restrictions
- Examples: `workbrew.nix`, `local-reverse-proxy.nix`

**`hm/`** - Cross-platform user environment modules
- Shell, terminal, development tools, GPG configurations
- Contains platform-specific conditionals (`isDarwin`/`isLinux`)
- Examples: `terminal.nix`, `shell.nix`, `development-environment.nix`

**`hosts/`** - Host-specific configurations
- NixOS: Single `nixos.nix` entry point (+ encrypted `hardware-configuration.nix`)
- macOS: Separate `nix-darwin.nix` and `home-manager.nix` entry points
- Examples: `framework-13-amd-ai-300/`, `nixos-desktop/`, `macos-work/`

### Supporting Files

**`dotfiles/`** - Direct-edit configuration files
- Neovim, shell functions, other frequently-edited configs
- Symlinked via `mkDotfilesLink`, bypassing Nix store rebuild cycle
- Also contains Neovim configuration, see below for details

**`globals.nix`** - Shared values passed to all modules

**`private.nix`** - Encrypted data (usernames, hostnames) passed to all modules

### Neovim Configuration

**`dotfiles/nvim/`** - Feature-based editor configuration (major portion of this repository)

**Entry point:**
- `dotfiles/nvim/init.lua` - Bootstraps lazy.nvim and loads features

**Organization:**
- Features organized using `dotfiles/nvim/lua/features.lua` utility (see file for details)
- Start with inline features in `dotfiles/nvim/init.lua`
- Extract to separate files only when "really inconvenient"
- Files organized by objective, not by category or plugin
- Each extracted file begins with comment explaining its objective

## Key Design Decisions and Trade-offs

### Use Nix flakes as the foundation for all configurations

Single system managing NixOS, macOS, and dotfiles ensures reproducibility and prevents configuration drift between machines.

- Everything defined through a single flake.nix
- Shared evaluation context helps avoid drift between systems
- Platform detection (pkgs.stdenv.isDarwin/isLinux, targetOS) enables conditional logic
- Sensitive data can be localized in separate files and still be in a shared evaluation context
- Lock file ensures exact reproducibility months later

### Organize modules by objectives, not technologies

Configuration should be self-documenting about what value it provides, not what tools it uses. This forces clarity about purpose.

- Modules named after goals: nixos/desktop.nix not hyprland.nix
- Documentation distinguishes "value provided" from "implementation used"
- Inline sub-modules pattern groups related features within objectives
- Each file starts with a comment explaining the objective
- See `README.md` "Configuration Philosophy" for complete methodology

### Make frequently-edited configs directly editable via dotfiles

Neovim and shell configurations change multiple times per day. Rebuilding for every tweak would kill productivity.

- dotfiles/ directory contains directly editable files
- mkDotfilesLink creates symlinks from ~/.config/ to ~/nix/dotfiles/
- Repository must be at ~/nix on all machines (hardcoded in helper)
- Changes take effect immediately without rebuild
- Trade-off: No rollback via Nix generations for these files

### Separate work and personal contexts automatically

Same machine used for both personal and work projects creates identity leakage risks.

- Git conditionally applies configs based on directory (~/Work/)
- Different credentials: email, GPG key, SSH key
- Automatic switching prevents accidental cross-contamination
- Configured in hm/development-environment.nix

### Platform-specific architecture for optimal performance

macOS nix-darwin rebuilds are slow (10+ seconds), NixOS rebuilds are relatively fast.

- macOS: Separate flake outputs for nix-darwin and home-manager
- NixOS: Merged configuration for convenience
- Allows quick home-manager updates on macOS without system rebuild
- Platform detection via targetOS parameter passed to modules

### Invest heavily in Neovim as the primary development interface

Need a fully programmable, modal editor that can be shaped exactly to personal workflow.

- Major portion of configuration effort (significant part of this repository)
- Neovim has a lot of plugins that simplify its configuration
- Lua brings flexibility when no plugin exists for a particular need
- Direct editing via dotfiles for instant feedback

### Organize Neovim by objectives using a features wrapper

Neovim represents a major portion of this configuration. Traditional plugin-based organization obscures the capabilities being built. Organizing by technical categories (UI, LSP, etc.) doesn't explain why features exist.

- Features organized via `dotfiles/nvim/lua/features.lua` wrapper around lazy.nvim
- Each feature defines an objective: "Enable tree-sitter usage", "Git interface like EMACS's Magit"
- Start monolithic in `dotfiles/nvim/init.lua`, extract to separate files only when really inconvenient
- Anti-perfectionism: avoid premature file organization
- When extracting, organize by objective (not category): name file after what you want to achieve
- Mirrors objective-based module organization throughout the Nix configuration

## Important Constraints

- Actual system changes (application of updated configuration) require manual approval
- Never stage, unstage or commit unless explicitly requested
- Validation commands in @AGENTS.md must pass before any commit

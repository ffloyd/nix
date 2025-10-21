# ai-tooling-config Specification

## Purpose
TBD - created by archiving change share-ai-assistant-rules. Update Purpose after archive.

## Requirements
### Requirement: Separate AI Tooling Home Manager Submodule

The system SHALL provide a dedicated home-manager submodule `hm/development-environment/ai-tooling.nix` that configures AI coding assistants (Claude Code and OpenCode) by generating tool-specific command and agent files from shared instruction content.

#### Scenario: adding new AI tool

- **WHEN** new AI tool configuration is needed (except Neovim plugins/configs)
- **THEN** configuration entrypoint is `hm/development-environment/ai-tooling.nix`
- **AND** it is an home-manager module that has inline submodules in its `imports` list (like other home-manager modules)
- **AND** it is imported in `hm/development-environment.nix`
- **AND** stores shared content that can be used "as is" in `dotfiles/ai-shared/`
- **AND** stores shared snippets needed for tool-specific generation in `hm/development-environment/ai-tooling/`

### Requirement: Cross-tool Shared Instructions Management

The system SHALL store instruction content based on whether it can be shared "as is" or needs tool-specific generation.

#### Scenario: Content shared as-is between tools

- **WHEN** content is identical for both tools (e.g., coding rules)
- **THEN** content is stored in `dotfiles/ai-shared/`
- **AND** both tools symlink directly to the same file (editable, out-of-store)

#### Scenario: Shared content needs tool-specific adjustments

- **WHEN** content requires different adjustments (usually frontmatter) for each tool (e.g., commit/review instructions)
- **THEN** shared content is stored in `hm/development-environment/ai-tooling/` directory in proper format (usually Markdown)
- **AND** tool-specific files are generated via Nix with appropriate adjustments (usually frontmatter prepended)

### Requirement: Simple Management of Tool-Specific Files

The system SHALL support simple creation of tool-specific files in tool-specific directories.

#### Scenario: Create and edit a tool-specific config file in a tool-specific directory

- **WHEN** user creates a file in a tool-specific directory (e.g., `dotfiles/opencode/agent/`, `dotfiles/claude/commands/`)
- **AND** user runs home-manager rebuild
- **THEN** file is symlinked and appears in corresponding location in home directory
- **AND** editing file content requires no rebuild

### Requirement: Directory Symlinks Helper Function

The system SHALL provide `mkDotfilesDirectoryEntriesSymlinks` helper function to iterate over directory files and create individual symlinks.

#### Scenario: Populating directory that already has Nix-generated files (symlinks to Nix store)

- **WHEN** `mkDotfilesDirectoryEntriesSymlinks` is called for a directory
- **THEN** function creates individual symlinks for each regular file in that directory
- **AND** already existing Nix-generated files (symlinks to Nix store) are preserved and not overwritten

### Requirement: Documentation of Workflow

The system SHALL provide clear documentation of the experimentation-to-sharing workflow in project documentation.

#### Scenario: README documents AI tooling approach

- **WHEN** developer reads README.md
- **THEN** documentation includes dedicated "AI Tooling" section after "Repository structure"
- **AND** documentation explains two types of AI files: Nix-generated (immutable) vs tool-specific that can be experimental (mutable)
- **AND** documentation explains `hm/development-environment/ai-tooling/` purpose (shared instruction content)
- **AND** documentation describes experimentation workflow (create in one tool → test → nixify for all tools)
- **AND** documentation explains mixed directories (both types coexist in home directory)
- **AND** documentation explains rebuild requirements (new files need rebuild, editing existing doesn't)
- **AND** "Repository structure" table is updated to reflect AI tooling structure


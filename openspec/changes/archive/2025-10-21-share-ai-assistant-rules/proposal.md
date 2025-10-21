## Why

Claude Code and OpenCode both need coding rules and specialized instructions (commit/review), but can't share them due to different frontmatter formats. Duplication creates maintenance burden and inconsistency risk.

## What Changes

Implement three-tier system for AI assistant configuration:

1. **Shared "as is"** (`dotfiles/ai-shared/`): Content identical for both tools → direct symlinks (editable)
2. **Shared snippets** (`hm/development-environment/ai-tooling/`): Content needing tool-specific frontmatter → Nix generation (immutable)  
3. **Experimental** (tool-specific `dotfiles/` dirs): Single-tool experiments → direct symlinks (editable, rebuild to discover)

Add `mkDotfilesDirectoryEntriesSymlinks` helper to support mixed directories (generated + experimental files coexist).

Create `hm/development-environment/ai-tooling.nix` submodule for centralized AI tooling configuration.

## Impact

**New spec:** `ai-tooling-config`

**New structure:**
- `hm/development-environment/ai-tooling.nix` - AI tooling submodule
- `hm/development-environment/ai-tooling/` - shared snippets for generation
- `dotfiles/ai-shared/` - content shared "as is"
- `mkDotfilesDirectoryEntriesSymlinks` in `flake.nix`

**Changed files:**
- `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md` - symlink to `dotfiles/ai-shared/coding-rules.md`
- `~/.claude/commands/`, `~/.config/opencode/{command,agent}/` - mixed directories (generated + experimental)

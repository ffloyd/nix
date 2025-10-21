## 1. Setup Phase

- [x] 1.1 Add `mkDotfilesDirectoryEntriesSymlinks` helper function to `flake.nix` specialArgs
- [x] 1.2 Create `hm/development-environment/` directory
- [x] 1.3 Create `hm/development-environment/ai-tooling.nix` submodule skeleton with imports structure
- [x] 1.4 Create `hm/development-environment/ai-tooling/` directory for shared snippets
- [x] 1.5 Create `dotfiles/ai-shared/` directory for content shared "as is"
- [x] 1.6 Update `hm/development-environment.nix` to import `./development-environment/ai-tooling.nix`

## 2. Extract Shared Content

- [x] 2.1 Extract coding rules from `dotfiles/claude/CLAUDE.md` to `dotfiles/ai-shared/coding-rules.md`
- [x] 2.2 Remove old manual `dotfiles/claude/CLAUDE.md`
- [x] 2.3 Extract shared commit logic from existing commit commands to `hm/development-environment/ai-tooling/commit-instructions.md`
- [x] 2.4 Extract shared review logic from existing review commands to `hm/development-environment/ai-tooling/review-instructions.md`

## 3. Implement AI Tooling Configuration

- [x] 3.1 Move AI assistant packages (claude-code, opencode, openspec, etc.) to `ai-tooling.nix`
- [x] 3.2 Remove AI tooling inline configuration from `hm/development-environment.nix`
- [x] 3.3 Setup direct symlink for `.claude/CLAUDE.md` to `dotfiles/ai-shared/coding-rules.md`
- [x] 3.4 Setup direct symlink for `.config/opencode/AGENTS.md` to `dotfiles/ai-shared/coding-rules.md`
- [x] 3.5 Generate `.claude/commands/commit.md` with Claude-specific frontmatter + `commit-instructions.md` content
- [x] 3.6 Generate `.claude/commands/review.md` with Claude-specific frontmatter + `review-instructions.md` content
- [x] 3.7 Remove old manual `dotfiles/claude/commands/commit.md`
- [x] 3.8 Remove old manual `dotfiles/claude/commands/review.md`
- [x] 3.9 Generate `.config/opencode/command/commit.md` with OpenCode-specific frontmatter + `commit-instructions.md` content
- [x] 3.10 Generate `.config/opencode/agent/review-staged.md` with OpenCode-specific frontmatter + `review-instructions.md` content
- [x] 3.11 Remove old manual `dotfiles/opencode/agent/review-staged.md`
- [x] 3.12 Setup `mkDotfilesDirectoryEntriesSymlinks` for `.claude/commands/` → `dotfiles/claude/commands/`
- [x] 3.13 Setup `mkDotfilesDirectoryEntriesSymlinks` for `.config/opencode/command/` → `dotfiles/opencode/command/`
- [x] 3.14 Setup `mkDotfilesDirectoryEntriesSymlinks` for `.config/opencode/agent/` → `dotfiles/opencode/agent/`
- [x] 3.15 Keep `.claude/settings.json` and `.config/opencode/opencode.jsonc` as direct symlinks

## 4. Validation

- [x] 4.1 Run `nix fmt .`
- [x] 4.2 Run `statix check`
- [x] 4.3 Run `nix flake check`
- [x] 4.4 Run `nixos-rebuild dry-build --flake .`
- [x] 4.5 Run `nixos-rebuild dry-activate --flake .`

## 5. Documentation

- [x] 5.1 Add "AI Tooling" section to README.md after "Repository structure":
  - Explain three-tier system: shared "as is", shared snippets, experimental
  - Document `dotfiles/ai-shared/` for content shared identically (editable, no rebuild)
  - Document `hm/development-environment/ai-tooling/` for shared snippets (immutable, rebuild required)
  - Document tool-specific dirs for experimental files (editable, rebuild to discover)
  - Explain mixed directories (generated + experimental coexist)
  - Document workflow: experiment → share (as-is or with generation)
- [x] 5.2 Update "Repository structure" table in README.md:
  - Add `dotfiles/ai-shared/` - AI content shared identically between tools
  - Add `hm/development-environment/ai-tooling/` - AI shared snippets for generation
  - Update `dotfiles/claude/`, `dotfiles/opencode/` - mention experimental AI files
- [x] 5.3 Update AGENTS.md:
  - Three-tier system explanation
  - Experimentation workflow (create → test → nixify)
  - Rebuild requirements (new files need rebuild, edits don't)

## Manual Testing Checklist

After completing tasks 1-5, verify:

1. **File permissions**:
   - Generated files are read-only: `~/.claude/commands/commit.md`, `~/.claude/commands/review.md`, `~/.config/opencode/command/commit.md`, `~/.config/opencode/agent/review-staged.md`
   - Direct symlinks are editable: `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`, `~/.claude/settings.json`, `~/.config/opencode/opencode.jsonc`

2. **Functionality**:
   - Claude Code commit command works
   - Claude Code review command works
   - OpenCode commit command works
   - OpenCode review-staged agent works

3. **Experimental files workflow**:
   - Create `dotfiles/claude/commands/test.md`, rebuild, verify appears in `~/.claude/commands/test.md`
   - Create `dotfiles/opencode/agent/test.md`, rebuild, verify appears in `~/.config/opencode/agent/test.md`
   - Edit experimental files, verify changes appear immediately without rebuild
   - Verify mixed directories: generated and experimental files coexist

4. **Shared content behavior**:
   - Edit `dotfiles/ai-shared/coding-rules.md`, verify changes appear immediately in both tools (no rebuild needed)
   - Edit `hm/development-environment/ai-tooling/commit-instructions.md`, rebuild, verify changes in generated files

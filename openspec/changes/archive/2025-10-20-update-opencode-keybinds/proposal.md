# Update OpenCode Keybindings

## Why

The default OpenCode keybindings for navigating between subagent sessions (`ctrl+left` and `ctrl+right`) conflict with system-level workspace navigation shortcuts on both NixOS (Hyprland) and macOS. This makes the feature unusable without rebinding.

## What Changes

- Change `session_child_cycle` from `ctrl+right` to `<leader>right`
- Change `session_child_cycle_reverse` from `ctrl+left` to `<leader>left`

## Impact

- Affected specs: `opencode-config`
- Affected code: `dotfiles/opencode/opencode.jsonc`

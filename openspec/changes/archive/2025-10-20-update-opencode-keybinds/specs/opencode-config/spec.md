# OpenCode Configuration

## ADDED Requirements

### Requirement: Subagent Session Navigation Keybindings

The OpenCode configuration SHALL define custom keybindings for navigating between subagent sessions that do not conflict with system-level workspace navigation shortcuts.

#### Scenario: Navigate to next subagent session

- **WHEN** user presses `<leader>right` in OpenCode
- **THEN** OpenCode cycles to the next child session

#### Scenario: Navigate to previous subagent session

- **WHEN** user presses `<leader>left` in OpenCode
- **THEN** OpenCode cycles to the previous child session

#### Scenario: No conflict with workspace navigation

- **WHEN** user presses `ctrl+left` or `ctrl+right` in OpenCode
- **THEN** the system-level workspace navigation is triggered instead of session cycling

---
description: Commits staged changes with a well-structured message.
allowed-tools: Glob, Grep, LS, Read, Bash(git status --porcelain), Bash(git diff --cached), Bash(git log -n 10 --pretty=format:"%s"), Bash(git commit:*)
---

## Context

- current status: !`git status --porcelain`
- staged changes: !`git diff --cached`
- recent commit messages: !`git log -n 10 --pretty=format:"%s"`
- read modified files if necessary
- ignore unstaged or untracked changes

## Task

- categorize changes (feat, fix, docs, style, refactor, test, chore, etc.)
- create a commit message
    - follow conventional commit format
    - respect to existing commit messages
    - prefer 1-line messages when it's enough
    - use short, focused messages
- ask for confirmation before committing
- execute the commit with the finalized message

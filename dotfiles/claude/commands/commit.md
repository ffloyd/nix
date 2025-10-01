---
description: Commits staged changes with a well-structured message.
allowed-tools: Glob, Grep, LS, Read, Bash(git status --porcelain), Bash(git diff --cached), Bash(git log:*), Bash(git commit:*)
---

## Context

- current status: !`git status --porcelain`
- staged changes: !`git diff --cached`
- recent commit messages: !`git log -n 10 --pretty=format:"%s"`
- read modified files if necessary
- DO NOT use `git add`, ignore unstaged or untracked changes

## Task

1. categorize changes (feat, fix, docs, style, refactor, test, chore, etc.)
2. create a commit message
    - follow conventional commit format
    - respect to existing commit messages
    - prefer 1-line messages when it's enough
    - use short, focused messages
3. MANDATORY: Ask for explicit user confirmation and wait for their response before executing git commit. Never commit without explicit user approval.
4. execute the commit with the finalized message

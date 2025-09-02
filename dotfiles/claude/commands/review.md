---
description: Reviews staged changes and provides detailed analysis before committing.
allowed-tools: Bash, Git, Glob, Grep, LS, Read
---

## Context

- current status: !`git status --porcelain`
- staged changes: !`git diff --cached`
- recent commit messages: !`git log -n 10 --pretty=format:"%s"`
- read modified and related files if necessary to understand context
- focus only on staged changes, ignore unstaged or untracked changes

## Task

- understand the nature of changes (e.g., feature, bug fix, documentation, etc.)
- understand the intent behind the changes
- if unclear, ask user for clarification on specific changes
- analyze the changes:
    - do they follow best practices?
    - are they consistent with existing code and architecture?
    - are introduces benefits outweighed by any potential drawbacks?
    - is it something worth doing at all?
    - can it be significantly simplified with low effort?
- provide a short review of identified issues or improvements

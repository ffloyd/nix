## Context

- current status: !`git status --porcelain`
- staged changes: !`git diff --cached`
- recent commit messages: !`git log -n 10 --pretty=format:"%s"`
- read modified files if necessary
- DO NOT use `git add`
- ignore unstaged or untracked changes

## Task

1. categorize changes (feat, fix, docs, style, refactor, test, chore, etc.)
2. create a commit message
    - follow conventional commit format (deviate only when repository uses different convention)
    - match the commit message format used by recent commits in the repository
    - prefer 1-line messages when it's enough
    - use short, focused messages
3. MANDATORY: Ask for explicit user confirmation and wait for their response before executing git commit. Never commit without explicit user approval.
4. execute the commit with the finalized message

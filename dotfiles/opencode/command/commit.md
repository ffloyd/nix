---
description: Create and commit staged changes with well-structured message
agent: general
subtask: false
---

## Context

Repository state:
!`git status --porcelain`

Staged changes:
!`git diff --cached`

Recent commit style:
!`git log -n 10 --pretty=format:"%s"`

## Task

1. **Analyze Changes**
   - Categorize: feat, fix, docs, style, refactor, test, chore, build, ci, perf, revert
   - Understand the scope and impact

2. **Create Commit Message**
   - Follow conventional commit format
   - Match existing commit message style
   - Prefer concise 1-line format when sufficient
   - Be specific and focused on "why", not "what"
   - Format: `<type>(<scope>): <subject>`
   - Example: `feat(auth): add password reset flow`

3. **Get Approval**
   - **MANDATORY**: Present the commit message
   - **MANDATORY**: Ask for explicit user confirmation
   - **MANDATORY**: Wait for user approval before executing

4. **Execute Commit**
   - After approval: `git commit -m "your message"`
   - Report success/failure

**Important**:
- DO NOT use `git add` - work only with staged changes
- DO NOT commit without explicit user approval
- If user requests changes, iterate on message and re-confirm

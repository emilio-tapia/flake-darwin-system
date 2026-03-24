---
name: version-control
description: Git expert — commits, grouping strategy, branches, tags, releases, history, diffs, conflict resolution. Handles all git situations and advises on when/how to commit.
allowed-tools: Bash(git *), Bash(gh *), Bash(ls *), Read, Glob, Grep, Edit, Write
argument-hint:
  [
    action: commit | status | log | diff | branch | tag | release | sync | cherry-pick | resolve | help,
  ]
---

# Git Expert Skill

Complete git management for the nix-darwin flake configuration repository. Handles ALL git operations, advises on commit strategy, and maintains clean history.

---

## 1. Commit Format

This repo uses parenthesized type format (matching existing history):

```
(type): description

<optional body — the "why">
```

**No `Co-Authored-By` lines.** No Claude attribution in commit messages.

### Types:

| Type | Description |
|------|------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Restructuring, no behavior change |
| `docs` | Documentation only |
| `chore` | Maintenance, config, dependencies |
| `style` | Formatting, whitespace only |
| `package` | Adding/removing packages |

### Scopes (optional, from project structure):

`flake`, `darwin`, `home-manager`, `hosts`, `homebrew`, `devenv`, `docs`

Examples from repo history:
```
(chore): add new packages brew and nix
(chore): change comment
(package): add claude code with homebrew
```

---

## 2. When to Commit — Decision Guide

### One commit when:
- All changes serve a **single logical purpose**
- Files changed are tightly coupled (e.g., `flake.nix` + `flake.lock`)
- Reverting the change should undo everything together

### Multiple commits when:
- Changes serve **different purposes** (a fix AND a refactor)
- Changes touch **independent areas** (darwin modules vs. home-manager configs)
- Some changes are **infrastructure** and others are **features/fixes**
- You could meaningfully revert one group without affecting the other

### Rule of thumb:
> "If I need the word 'and' to connect unrelated things in a commit message, it should be two commits."

---

## 3. How to Group Changes

### Analysis phase (always do this first):
1. `git status` — see everything pending
2. `git diff --stat` — understand scope
3. `git diff` per file or group — understand what changed
4. Read content of new (untracked) files
5. `git log --oneline -10` — understand existing commit style

### Grouping strategy:

**Step 1 — Classify each changed file:**
- A **type** (feat/fix/refactor/docs/chore/package)
- A **scope** (flake/darwin/home-manager/hosts/homebrew/devenv/docs)
- A **purpose** (one-line: what does this change accomplish?)

**Step 2 — Cluster by purpose:**
Files with the same purpose go in one commit. Common clusters for this repo:
- `flake.nix` + `flake.lock` (input changes always together)
- Darwin module + its host-specific enable file
- Multiple home-manager configs that got the same fix
- Homebrew configs across hosts for the same change

**Step 3 — Order commits by dependency:**
1. `flake.nix` + `flake.lock` first (everything depends on inputs)
2. Darwin modules (`darwinModules/`)
3. Host-specific configs (`hosts/`)
4. Home Manager configs (`home_manager/`)
5. Documentation (`docs/`)
6. Tooling/chore (`.claude/`, `.gitignore`, etc.)

**Step 4 — Present the plan to the user:**
Before committing anything, show:
```
Proposed commits:
  1. (refactor): unify flake inputs to 25.05
     - flake.nix
     - flake.lock
  2. (fix): dynamic PostgreSQL user via specialArgs
     - darwinModules/development/devTools.nix
  3. (chore): fix homebrew cask names and cleanup
     - hosts/m4Pro/homeBrew.nix
     - hosts/macbookPro/homeBrew.nix
```
Wait for user confirmation before proceeding.

---

## 4. Commit Workflow

For each commit group:

1. **Stage files** — `git add` specific files only (NEVER `git add .` or `git add -A`)
2. **Create commit** — using HEREDOC format:
   ```bash
   git commit -m "$(cat <<'EOF'
   (type): description

   Body explaining why.
   EOF
   )"
   ```
3. **Verify** — `git log --oneline -1` and `git status`

Repeat for each commit group.

### After all commits:
```bash
git log --oneline -N   # show all new commits
git status              # verify clean tree
```

---

## 5. Edge Cases

### Mixed changes (feat + fix in same file):
- If the fix is part of the feature → single commit
- If the fix is independent → split into two commits, fix first

### Large refactors:
- Touching 10+ files for the same reason → single commit is fine
- Explain scope in the commit body

### flake.lock changes:
- ALWAYS commit `flake.lock` together with `flake.nix` input changes
- If `flake.lock` updated alone (via `nix flake update`), commit as `(chore): update flake.lock`

### Nix-specific patterns:
- When a darwin module changes signature (e.g., adding `user` to args), include all files that consume that module in the same commit
- When commenting out unavailable packages, group by reason (e.g., "not in nixpkgs-25.05" packages together)

---

## 6. Other Git Operations

### status
Show: branch, pending changes, stashes, recent commits.

### log
Default: last 20 commits. Support filters by author, date, file, graph view.

### diff
Always show `--stat` first for context, then full diff if needed.

### branch
Naming: `feature/`, `fix/`, `refactor/`

### tag
Create, list, delete (with confirmation), push (with confirmation).

### release
1. Verify clean working tree
2. Collect commits since last tag
3. Generate changelog grouped by type
4. Create annotated tag with changelog
5. Push only if user confirms

### sync
Fetch, show ahead/behind status. NEVER push automatically.

### cherry-pick
Identify, confirm with user, apply, handle conflicts.

### resolve
Show conflicts, propose resolution, apply only with user confirmation.

---

## 7. Safety Rules

**NEVER execute without user confirmation:**
- `git push` (any variant)
- `git reset --hard`
- `git branch -D` (force delete)
- `git rebase` on shared branches
- `git stash drop`
- `git clean -f`

**NEVER use:** `--force`, `--no-verify`

**NEVER commit:** `.env`, credentials, API keys, secrets

**Always:**
- Verify active branch before destructive operations
- Prefer reversible operations
- Present commit plan before executing
- Use HEREDOC for commit messages
- Create NEW commits after hook failures (never `--amend`)

---

## User Request

$ARGUMENTS

Interpret the requested action and execute. If unclear, show available actions and ask. If the user just says "commit", run the full analysis → grouping → commit workflow.

---
name: github-integration
version: 1.1.0
description: Use when working on a tracked project that should be backed by GitHub — creates or updates the project repo (always prompting for org/name, private by default), creates issues for tasks, manages labels, creates branches, and links PRs back to issues
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [setup or sync]
---

# GitHub Integration

Turn Crucible tasks into GitHub issues with labels, branches, and linked PRs. The GitHub issue becomes the single source of truth for each task's status. This skill also bootstraps the GitHub repo itself if the project doesn't have one yet.

**Works for everyone.** Beginners get explanations of what's happening and why; experts get a terse path through the same steps. Adjust the verbosity to match who you're working with — if the user just said "I've never used GitHub before," slow down and teach; if they're dropping `gh` commands, skip the hand-holding.

**Announce at start:** "I'm using the github-integration skill to sync with GitHub."

## When to Use

- Any project that should live on GitHub (new or existing)
- Need to track tasks as GitHub issues
- Creating branches and PRs for completed work
- Updating issue status as tasks progress
- First-time GitHub setup for a brand-new user

## Core Pattern

### Step 0: Ensure the Project Repo Exists (ALWAYS run first)

Before any labels or issues, make sure a GitHub repo backs this project. **This step is designed for both beginners and experts** — take the time to explain concepts when the user seems new, and be fast/silent when they clearly know the tools. If unsure, err toward explaining.

#### 0a. Preflight: is the user ready to use GitHub?

Run these checks silently and only surface problems:

```bash
gh --version              # is GitHub CLI installed?
gh auth status            # is the user logged in?
git --version             # is git installed?
git config user.name      # is git identity configured?
git config user.email
```

If any check fails, **pause and walk the user through it** — don't try to proceed. Example beginner-friendly messages:

- **`gh` not installed:** "GitHub CLI (`gh`) is the tool that lets me talk to GitHub from the terminal. Install it from https://cli.github.com/ and come back — takes about a minute."
- **`gh auth status` shows not logged in:** "You need to log in to GitHub once. Run `gh auth login` — it'll walk you through a browser-based login. I'll wait."
- **`git config user.name` empty:** "Git needs to know who you are so commits have an author. Run: `git config --global user.name 'Your Name'` and `git config --global user.email 'you@example.com'`."

For experts who've done this a hundred times, just note "preflight OK" and move on.

#### 0b. Check what already exists

```bash
git rev-parse --is-inside-work-tree 2>/dev/null   # is this a git repo locally?
gh repo view --json nameWithOwner 2>/dev/null     # is a GitHub remote linked?
```

A "remote" is the GitHub copy your local code pushes to. "Linked" means `git push` knows where to go.

#### 0c. Branch on the result

**Case A — Remote already linked → UPDATE MODE.**
- Run Step 1 (labels) to make sure Crucible's labels exist on the repo.
- If `PLAN.md` changed locally since the last push, commit & push it.
- If the plan was updated, refresh the relevant section of `README.md` so a visitor can see the current roadmap.
- Continue to issue sync.

**Case B — Local repo but no remote → CREATE MODE (then link).** You'll create the GitHub repo and wire the existing local repo to it.

**Case C — No git repo at all → CREATE MODE (from scratch).** You'll `git init` first, then create and link.

#### 0d. Always prompt the user — never auto-pick

Ask explicitly, and explain the choices for someone who may not know:

> **I'm about to create a GitHub repo for this project. A quick explainer then a few questions:**
>
> A **GitHub repo** is the online home for your code. It stores history, tracks tasks as "issues", and is where other people (or other agents) can collaborate. For this workflow, GitHub issues become the to-do list that everyone shares.
>
> **Questions:**
> 1. **Where should it live (owner)?**
>    - `oscarwilsonengines` — Oscar Wilson / company work
>    - `zanijr` — your personal projects
>    - `zbonham` — your personal GitHub username (also fine for personal)
>    - (legacy `ZbOscar` is skipped — don't use for new projects)
>    - If you don't have a preference and this is just for you, `zbonham` is the safe default.
> 2. **Name?** (default: `$(basename "$PWD")` — the current folder name)
> 3. **Visibility?** I'll default to **private** (only you can see it). Say "public" if you want the world to see it.
> 4. **Description?** One-line summary for the repo's home page. Optional — I can skip it.

**Wait for the answer. Never fill in "obvious" defaults silently.** Even experts may want a different org today than yesterday.

#### 0e. Create & link the repo

Once the user answers, run the minimum needed. Narrate what you're doing in plain English for beginners (one sentence per command).

```bash
# If no git repo yet (Case C):
git init
git add -A
git commit -m "chore: initial commit"

# Create the GitHub repo and wire it up (Cases B & C).
# --source=. uses the current directory, --remote=origin names the link "origin",
# --push sends the first commit up so GitHub has a starting copy.
gh repo create {owner}/{name} --private --source=. --remote=origin --push \
  --description "{description if provided}"
```

For a public repo, swap `--private` for `--public`.

#### 0f. Seed the repo with starter files (new repos only)

If this is a brand-new repo, make it welcoming. Create these if they don't exist:

- `README.md` — project name, one-paragraph description, and a "Tasks" section that will be kept in sync with open issues
- `.gitignore` — use `gh repo edit --enable-issues` is not needed (issues are on by default), but a good `.gitignore` is. If the project is Python: `__pycache__/`, `.venv/`, `.env`; if Node: `node_modules/`, `dist/`, `.env`. Always include `.env` per global rules.
- `PLAN.md` — if Crucible already produced one, commit it now.

Commit and push these as `chore: scaffold project`.

#### 0g. Verify before moving on

```bash
gh repo view --web    # (optional) opens the repo in the browser so the user can see it
gh repo view --json nameWithOwner,visibility,url
```

Tell the user the URL and confirm the visibility: *"Created https://github.com/{owner}/{name} (private). Moving on to labels and issues."*

**Never auto-pick the org.** Even when the project clearly belongs somewhere (e.g., an Oscar Wilson app), still prompt — placement is an explicit user decision.

### Setup: Create Labels

On first use in a repo, create Crucible labels. See `references/label-schema.md` for the full set.

```bash
gh label create "crucible:todo" --color "0e8a16" --description "Ready for an agent" --force
gh label create "crucible:in-progress" --color "fbca04" --description "Agent working on it" --force
gh label create "crucible:blocked" --color "d93f0b" --description "Waiting on dependency" --force
gh label create "crucible:review" --color "1d76db" --description "Code complete, needs review" --force
gh label create "crucible:done" --color "6f42c1" --description "Merged and closed" --force
gh label create "crucible:critical" --color "b60205" --description "Review found critical issue" --force
gh label create "priority:p0" --color "b60205" --description "Do first" --force
gh label create "priority:p1" --color "d93f0b" --description "Do soon" --force
gh label create "priority:p2" --color "fbca04" --description "Do eventually" --force
```

### Create Issues for Tasks

For each task in the plan, create a GitHub issue. See `references/issue-template.md` for the body format.

```bash
gh issue create \
  --title "{task_title}" \
  --body "{issue_body}" \
  --label "crucible:todo,priority:{priority}"
```

Save the issue number to `task.issue_number` in plan.json.

### Update Labels as Tasks Progress

| Task Status | Label Change |
|-------------|-------------|
| `todo` → `in-progress` | Remove `crucible:todo`, add `crucible:in-progress` |
| `in-progress` → `review` | Remove `crucible:in-progress`, add `crucible:review` |
| `review` → `done` | Remove `crucible:review`, add `crucible:done`, close issue |
| Any → `blocked` | Add `crucible:blocked` |
| Any → `failed` | Add `crucible:critical` |

```bash
gh issue edit {issue_number} --remove-label "crucible:todo" --add-label "crucible:in-progress"
```

### Comment Progress

When a task makes progress:
```bash
gh issue comment {issue_number} --body "Progress: completed criterion X. (2/5 done)"
```

When a task completes:
```bash
gh issue comment {issue_number} --body "Task complete. All acceptance criteria met."
gh issue close {issue_number}
```

### Create PRs

After work is complete:
```bash
gh pr create --base main --title "feat: {task_title}" --body "Closes #{issue_number}"
```

## Common Mistakes

- Creating issues without acceptance criteria in the body → reviewers lack context
- Not updating labels → GitHub board becomes stale
- Creating PRs that don't reference issues → no audit trail
- Using generic labels instead of crucible-namespaced ones → conflicts with other tools

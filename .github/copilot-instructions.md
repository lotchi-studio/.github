# Copilot Instructions - Lotchi Studio .github Repository

## What This Repo Does

Organization-wide defaults repository. Files here apply to ALL Lotchi Studio repos that don't have their own versions. **Do not edit for a single project**—changes affect the entire org.

## Architecture

```
.github/
├── workflows/ci.yml           # PR validation (YAML syntax, merge conflicts)
├── workflows/release.yml      # Full release pipeline (changelog → release → docs → Slack)
├── ISSUE_TEMPLATE/            # Bug, feature, task templates (YAML form-based)
├── CODEOWNERS                 # All PRs → @healkeiser
└── pull_request_template.md
.scripts/git/                  # PowerShell versioning (IncrementVersion.ps1, ShowCurrentVersion.ps1)
```

## Release Pipeline (Critical Flow)

Triggered by `v*.*.*` tags. Sequential jobs with dependencies:

1. **update-package-version** → Bumps `package.py` for Rez packages (optional)
2. **generate-changelog** → `auto-changelog` generates CHANGELOG.md, commits `[DOC] CHANGELOG`
3. **create-release** → Draft GitHub release with extracted changelog section
4. **deploy-docs** → MkDocs to GitHub Pages (if `mkdocs.yml` exists)
5. **notify-slack** → Posts to Slack webhook

The workflow uses GitHub App token (`APP_ID`/`APP_PRIVATE_KEY` secrets) to bypass branch protection for automated commits.

## Commit Message Prefixes (Required)

Parsed by `.auto-changelog` config—use exact format:
- `[FEAT]` - New feature
- `[FIX]` or `[BUG]` - Bug fixes
- `[DOC]` - Documentation (auto-used for CHANGELOG commits)
- `[STYLE]` - Formatting, naming
- `[BUILD]` - CI/build changes
- `[MISC]` - Other (filtered from changelog by default)

## Version Management

```powershell
# Use VS Code tasks or run directly:
.\.scripts\git\IncrementVersion.ps1 patch  # v1.0.0 → v1.0.1
.\.scripts\git\IncrementVersion.ps1 minor  # v1.0.0 → v1.1.0
.\.scripts\git\IncrementVersion.ps1 major  # v1.0.0 → v2.0.0
```

Script creates + pushes tag immediately. First tag defaults to `v0.1.0`.

## Workflow Reuse Pattern

Other repos call these workflows via `workflow_call`:
```yaml
uses: lotchi-studio/.github/.github/workflows/release.yml@main
with:
  python-version: '3.13'
  skip-changelog: false
secrets:
  APP_ID: ${{ secrets.APP_ID }}
  APP_PRIVATE_KEY: ${{ secrets.APP_PRIVATE_KEY }}
```

Key inputs: `node-version`, `python-version`, `skip-changelog`, `skip-docs`, `update-package-py`

### Rez Package Support

For repos using Rez, set `update-package-py: true` to auto-bump `package.py` version on release:
```yaml
with:
  update-package-py: true
  package-py-path: "package.py"  # default path
```
The workflow updates `version = "X.Y.Z"` in package.py before changelog generation.

## Required Secrets

| Secret | Purpose | Required? |
|--------|---------|-----------|
| `APP_ID` | GitHub App ID for bypassing branch protection | Yes, for automated commits |
| `APP_PRIVATE_KEY` | GitHub App private key | Yes, for automated commits |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook for release notifications | Optional |
| `GH_TOKEN` | GitHub token for `git-committers` MkDocs plugin | Optional, for docs |

## Key Files to Know

| File | Purpose |
|------|---------|
| `.auto-changelog` | Changelog template config; `ignoreCommitPattern` filters `[DOC]`, `[MISC]`, `[skip ci]` |
| `mkdocs.yml` | MkDocs Material theme config; uses `git-committers` plugin (requires `GH_TOKEN`) |
| `package.json` | Only contains `auto-changelog` dev dependency |

## Don't Do

- Don't commit `package-lock.json`—workflow removes it after changelog generation
- Don't manually edit CHANGELOG.md on main—it's auto-regenerated on release
- Don't create non-reusable workflows—everything should support `workflow_call`

## Note on Legacy Workflows

The previous separate workflows (`check_pylint.yml`, `check_black_formatter.yml`, `generate_changelog.yml`, `generate_documentation.yml`, `create_release.yml`) have been consolidated into:
- [ci.yml](.github/workflows/ci.yml) — PR validation only
- [release.yml](.github/workflows/release.yml) — Full release pipeline (handles all post-merge automation)

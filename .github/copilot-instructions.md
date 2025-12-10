# Copilot Instructions - Lotchi Studio .github Repository

## Repository Purpose

This is a special GitHub `.github` repository that provides organization-wide defaults and reusable workflows for all Lotchi Studio projects. Files in this repo automatically apply to other repositories in the organization when they don't have their own versions.

## Project Structure

```
.github/
├── workflows/           # Reusable GitHub Actions workflows
├── ISSUE_TEMPLATE/      # Issue templates for all repos
├── CODEOWNERS           # Default code review assignments (@healkeiser)
└── pull_request_template.md
scripts/git/             # PowerShell version management scripts
profile/                 # Organization profile README
```

## Key Workflows

### Reusable Workflows (workflow_call)
All workflows support `workflow_call` with optional inputs and additional custom steps:
- **generate_changelog.yml**: Auto-generates CHANGELOG.md using `auto-changelog` library, commits with `[DOC] CHANGELOG` message
- **generate_documentation.yml**: Builds and deploys MkDocs documentation to GitHub Pages (checks for `mkdocs.yml` first)
- **check_pylint.yml**: Runs pylint on all Python files
- **check_black_formatter.yml**: Validates Black formatting (strict check, no auto-fix)
- **create_release.yml**: Creates GitHub releases from version tags (triggered on `v*.*.*` tags)

### Workflow Customization Pattern
All reusable workflows follow this pattern:
```yaml
workflow_call:
  inputs:
    python-version: { default: '3.11' }  # or node-version
    additional-steps: { default: '' }    # Custom bash commands to append
```

## Version Management

### Semantic Versioning System
- Uses Git tags in `vX.Y.Z` format (e.g., `v0.2.9`)
- **PowerShell Scripts**: `scripts/git/increment_version.ps1` and `show_current_version.ps1`
- Run via VS Code tasks: "Show Current Version" or "Create and Push Git Tag"

### Incrementing Versions
```powershell
# From VS Code task (prompts for type)
./scripts/git/increment_version.ps1 major   # 1.0.0 -> 2.0.0
./scripts/git/increment_version.ps1 minor   # 1.0.0 -> 1.1.0
./scripts/git/increment_version.ps1 patch   # 1.0.0 -> 1.0.1
```
Script automatically creates and pushes the new tag, which triggers the release workflow.

## Commit Message Convention

Follow prefix patterns observed in CHANGELOG.md:
- `[DOC]` - Documentation updates (auto-generated for CHANGELOG)
- `[FIX]` - Bug fixes
- `[MISC]` - Miscellaneous changes
- `[STYLE]` - Visual/styling changes

## Python Project Standards

- **Python Version**: Default to `3.11` (configurable in workflows)
- **Formatter**: Black (enforced via CI, no auto-fix in PR checks)
- **Linter**: Pylint (runs on all `*.py` files)
- **Documentation**: MkDocs with mkdocstrings, mkdocs-material theme, git plugins

## Development Tasks

Available VS Code tasks (see `.vscode/tasks.json`):
- "Show Current Version" - Display current git tag
- "Create and Push Git Tag" - Increment version (prompts for type)
- "Deploy Documentation" - Run `mkdocs gh-deploy`
- "Generate Changelog" - Run `npm run changelog`

## PR Requirements

From `pull_request_template.md`, PRs must:
- Add/update unit tests if needed
- Update documentation if needed
- Pass local build and lint checks
- Update CHANGELOG.md manually (or let automation handle it on main)
- Specify PR type (bugfix, feature, refactoring, etc.) and breaking change status

## Important Notes

- **CODEOWNERS**: All files default to review by @healkeiser
- **Changelog Automation**: After merging to main, changelog is auto-generated and committed by github-actions bot
- **Package Management**: `package-lock.json` is intentionally removed after changelog generation (see workflow)
- **Workflow Permissions**: All workflows require `contents: write` permission for commits/tags

# Template Initialization

Automate project initialization from template-ts by driving the interactive script non-interactively. The script features intelligent defaults auto-detection from git config and environment, skills discovery based on project context, and automatic installation of specify tools for GitHub Copilot.

## When to Use

Use this prompt when the user wants to:
- Initialize a new project from the template-ts repository
- Set up a fresh repository with customized project metadata
- Configure package scope and remove example packages/tests
- Automate the entire `scripts/init-template.sh` workflow without manual prompts

## Workflow

1. **Detect intelligent defaults** - Auto-detect project name, author, email, repo URL from environment and git config
2. **Gather inputs** - Ask user for required fields with intelligent defaults pre-filled; only description typically needs manual input
3. **Discover skills** - Analyze project description to recommend relevant skills from https://skills.sh/
4. **Validate environment** - Check Node.js >= 20, pnpm >= 10, and scripts are executable
5. **Execute initialization** - Run init script with piped answers
6. **Install Copilot tools** - Automatically install specify and specify-extend with Copilot agent
7. **Verify setup** - Run lint and tests, report results

## Required Inputs

Collect these from the user before proceeding (or use intelligent defaults):

**Required:**
- `project_name` - Project name (default: auto-detected from `basename $(pwd)`)
- `author_name` - Author name (default: auto-detected from `git config user.name`)
- `description` - Project description (no default, user must provide)

**Optional (intelligent defaults provided):**
- `author_email` - Author email (default: auto-detected from `git config user.email`)
- `repository_url` - Repository URL (default: auto-detected from `git remote.origin.url`)
- `package_scope` - Package scope (default: extracted from project name, e.g., "acme-app" → "acme", fallback: "company")
- `remove_example_packages` - Remove example packages? (default: "y")
- `remove_example_tests` - Remove example tests? (default: "y")
- `remove_example_e2e` - Remove E2E tests? (default: "y")
- `replace_template_initialization` - Replace TEMPLATE_INITIALIZATION.md? (default: "y")

## Execution

Make scripts executable and pipe answers to init script:

```bash
chmod +x scripts/*.sh

# Example with intelligent defaults (most values will be auto-detected)
printf '%s\n' \
  "" \
  "" \
  "" \
  "$description" \
  "" \
  y \
  "" \
  "$remove_example_packages" \
  "$remove_example_tests" \
  "$remove_example_e2e" \
  "$replace_template_initialization" \
  | scripts/init-template.sh
```

**Note**: 
- Empty strings ("") will use intelligent defaults auto-detected from git config and environment
- The script will auto-detect: project name (from directory), author name/email (from git config), repo URL (from git remote), and package scope (from project name pattern)
- The 6th line (`y`) confirms to proceed after showing the configuration summary
- Skills discovery will run automatically based on the project description provided

## Features

### Intelligent Defaults Auto-Detection
- **Project name**: `basename $(pwd)`
- **Author name**: `git config user.name`
- **Author email**: `git config user.email`
- **Repository URL**: `git config remote.origin.url`
- **Package scope**: Extracted from project name (e.g., "acme-app" → "acme")

### Skills Discovery
- Runs `scripts/discover-skills.sh` to analyze project context
- Recommends relevant skills based on project name and description
- Skills matched against patterns from https://skills.sh/
- Output includes recommended skills list for the agent directories
- The script now automatically analyzes the project description and recommends relevant skills from https://skills.sh/
- This happens transparently during initialization
- Recommended skills will be available in agent-specific directories (.copilot/, .claude/, .codex/, .gemini/)

### Copilot Integration
- Automatically installs `uvx specify --ai copilot`
- Automatically installs `uvx specify-extend --agent copilot`
- Provides manual installation instructions if uvx unavailable
- The script automatically installs specify tools for GitHub Copilot
- If `uvx` is not available, the script provides instructions for manual installation

## Post-Initialization

Run validation commands:

```bash
pnpm run lint
pnpm test
```

## What Gets Updated

- `package.json` - Project metadata, author, description, repository
- `README.md` - Generated with project details
- `AGENTS.md` - Generated with project name and agent guidance (with correct "Copilot" capitalization)
- `scripts/TEMPLATE_INITIALIZATION.md` - Optionally replaced with starter guide
- `.copilot/skills/` - Skills directory created with symlinks to recommended skills
- Example packages/tests - Optionally removed based on user choices
- Git repository - Initialized with initial commit if not already present
- **Specify tools** - Installed automatically for GitHub Copilot integration

## Deliverables

Report to user:

- Configuration summary (inputs used, including auto-detected defaults)
- Discovered skills recommendations
- Commands executed
- Specify tools installation status
- Lint results
- Test results
- Location of updated files
- Skills available in .copilot/, .claude/, .codex/, .gemini/ directories

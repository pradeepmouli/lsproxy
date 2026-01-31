#!/bin/bash
# Skills discovery script
# Analyzes project context to suggest relevant skills to include
# Skills are based on the skill repository at https://skills.sh/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Get inputs
PROJECT_NAME="${1:-}"
PROJECT_DESCRIPTION="${2:-}"
PROJECT_TYPE="${3:-}"

if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_DESCRIPTION" ]; then
  echo "Usage: $0 <project_name> <project_description> [project_type]"
  echo ""
  echo "Example:"
  echo "  $0 'my-api' 'REST API for user management' 'backend'"
  exit 1
fi

# Available skills in .agents/skills/
AVAILABLE_SKILLS=(
  "changelog-automation"
  "crafting-effective-readmes"
  "dependency-updater"
  "dependency-upgrade"
  "design-system-patterns"
  "frontend-design"
  "game-changing-features"
  "github-actions-templates"
  "modern-javascript-patterns"
  "monorepo-management"
  "protocol-reverse-engineering"
  "responsive-design"
  "skill-creator"
  "turborepo-caching"
  "typescript-advanced-types"
  "visual-design-foundations"
)

# Skills to recommend based on keywords
declare -A SKILL_KEYWORDS

# Map keywords to skills
SKILL_KEYWORDS["changelog-automation"]="release|changelog|version|publish|npm"
SKILL_KEYWORDS["crafting-effective-readmes"]="documentation|readme|docs|library|package"
SKILL_KEYWORDS["dependency-updater"]="dependencies|deps|packages|update|upgrade"
SKILL_KEYWORDS["dependency-upgrade"]="upgrade|migration|breaking|major"
SKILL_KEYWORDS["design-system-patterns"]="design system|component library|tokens|theme|ui kit"
SKILL_KEYWORDS["frontend-design"]="frontend|ui|web|interface|website|landing|dashboard"
SKILL_KEYWORDS["game-changing-features"]="product|feature|strategy|roadmap|innovation"
SKILL_KEYWORDS["github-actions-templates"]="ci|cd|pipeline|workflow|actions|automation|deployment"
SKILL_KEYWORDS["modern-javascript-patterns"]="javascript|js|es6|async|promise|functional"
SKILL_KEYWORDS["monorepo-management"]="monorepo|workspace|multi-package|lerna|nx"
SKILL_KEYWORDS["protocol-reverse-engineering"]="protocol|network|packet|reverse|dissect"
SKILL_KEYWORDS["responsive-design"]="responsive|mobile|tablet|adaptive|breakpoint"
SKILL_KEYWORDS["skill-creator"]="skill|extension|plugin|custom"
SKILL_KEYWORDS["turborepo-caching"]="turborepo|build cache|distributed|performance"
SKILL_KEYWORDS["typescript-advanced-types"]="typescript|types|generic|utility|conditional"
SKILL_KEYWORDS["visual-design-foundations"]="typography|color|spacing|visual|design|aesthetic"

# Convert description and type to lowercase for matching
SEARCH_TEXT="${PROJECT_NAME,,} ${PROJECT_DESCRIPTION,,} ${PROJECT_TYPE,,}"

# Analyze and recommend skills
RECOMMENDED_SKILLS=()

print_info "Analyzing project context..."
echo ""

for skill in "${AVAILABLE_SKILLS[@]}"; do
  keywords="${SKILL_KEYWORDS[$skill]}"
  
  if [[ -n "$keywords" ]]; then
    # Check if any keyword matches
    if echo "$SEARCH_TEXT" | grep -qiE "$keywords"; then
      RECOMMENDED_SKILLS+=("$skill")
    fi
  fi
done

# Always recommend these core skills for TypeScript projects
CORE_SKILLS=(
  "typescript-advanced-types"
  "github-actions-templates"
  "dependency-updater"
)

for skill in "${CORE_SKILLS[@]}"; do
  if [[ ! " ${RECOMMENDED_SKILLS[@]} " =~ " ${skill} " ]]; then
    RECOMMENDED_SKILLS+=("$skill")
  fi
done

# Output recommended skills
if [ ${#RECOMMENDED_SKILLS[@]} -gt 0 ]; then
  print_success "Recommended skills for this project:"
  echo ""
  
  for skill in "${RECOMMENDED_SKILLS[@]}"; do
    echo "  • $skill"
  done
  
  echo ""
  echo "These skills will be available in:"
  echo "  - .copilot/skills/ (for GitHub Copilot)"
  echo "  - .claude/skills/ (for Claude)"
  echo "  - .codex/skills/ (for Codex)"
  echo "  - .gemini/skills/ (for Gemini)"
else
  print_info "No specific skills recommended. Using default skill set."
fi

# Export as comma-separated list for use in other scripts
echo ""
echo "RECOMMENDED_SKILLS=${RECOMMENDED_SKILLS[*]}"

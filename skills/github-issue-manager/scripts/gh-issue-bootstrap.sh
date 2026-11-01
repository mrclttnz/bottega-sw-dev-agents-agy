#!/usr/bin/env bash
# Bottega GitHub Issues Bootstrap Script
# Idempotently configures Bottega's standardized label taxonomy (type:*, priority:*, status:*)
# and optionally installs GitHub Issue Forms (.github/ISSUE_TEMPLATE/*.yml) in a target repository.
#
# Usage:
#   bash gh-issue-bootstrap.sh [--repo-dir /path/to/repo] [--install-templates] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_SRC_DIR="$SKILL_ROOT/references/issue-templates"

REPO_DIR="."
INSTALL_TEMPLATES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-dir)
      REPO_DIR="$2"
      shift 2
      ;;
    --install-templates)
      INSTALL_TEMPLATES=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--repo-dir <dir>] [--install-templates] [--dry-run]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

cd "$REPO_DIR"

echo "============================================================"
echo " Bottega GitHub Issue Manager — Repository Bootstrap"
echo " Target Repository: $(pwd)"
echo " Dry Run:           $DRY_RUN"
echo "============================================================"

# 1. Verify git repository & remote
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] $(pwd) is not inside a Git repository." >&2
  exit 1
fi

if ! git remote -v | grep -q "github.com"; then
  echo "[WARN] No github.com remote detected in 'git remote -v'. Proceeding with local template check..."
fi

# 2. Verify GitHub CLI (gh) unless in dry-run mode
if [[ "$DRY_RUN" == "false" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "[ERROR] GitHub CLI ('gh') is not installed. Install it via 'sudo apt install gh' (or brew/winget) and run 'gh auth login'." >&2
    exit 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    echo "[ERROR] GitHub CLI ('gh') is not authenticated. Run 'gh auth login' first." >&2
    exit 1
  fi
fi

upsert_label() {
  local name="$1"
  local color="$2"
  local desc="$3"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] Would upsert label: $name (#$color) — $desc"
  else
    gh label create "$name" --color "$color" --description "$desc" --force >/dev/null
    echo "[OK] Label synced: $name"
  fi
}

echo ""
echo "--- Syncing Bottega Standard Labels (type, priority, status) ---"

# Type labels
upsert_label "type:feature"     "0E8A16" "New user-facing capability or major functional requirement"
upsert_label "type:enhancement" "A2EEEF" "Iterative improvement or UX refinement to an existing feature"
upsert_label "type:bug"         "D73A4A" "Unexpected behavior, crash, regression, or broken edge case"
upsert_label "type:security"    "B60205" "Security vulnerability, Threat Model control, or AppSec hardening"
upsert_label "type:refactor"    "FBCA04" "Code quality, architectural cleanup, or tech debt reduction"
upsert_label "type:docs"        "0075CA" "Documentation alignment, ADR, schema doc, or runbook update"
upsert_label "type:chore"       "CFD3D7" "CI/CD, Docker, dependencies, build tooling, or infra maintenance"

# Priority labels
upsert_label "priority:critical" "B60205" "Blocker, outage, or critical/high security vulnerability"
upsert_label "priority:high"     "D93F0B" "High-value feature or important defect for the next slice"
upsert_label "priority:medium"   "FBCA04" "Standard backlog item planned for upcoming iterations"
upsert_label "priority:low"      "0E8A16" "Nice-to-have improvement, minor nit, or long-term idea"

# Status labels
upsert_label "status:triage"      "EDEDED" "Newly opened issue awaiting requirements/priority assessment"
upsert_label "status:needs-spec"  "D876E3" "Requires PRD/Architecture/DB Schema update before coding"
upsert_label "status:ready"       "0E8A16" "Scope and acceptance criteria clear; ready for implementation"
upsert_label "status:in-progress" "1D76DB" "Actively being implemented in a Bottega Vertical Slice"
upsert_label "status:blocked"     "B60205" "Blocked by external dependency, pending decision, or failed gate"

# 3. Install GitHub Issue Forms (.github/ISSUE_TEMPLATE/*.yml)
if [[ "$INSTALL_TEMPLATES" == "true" ]]; then
  echo ""
  echo "--- Installing GitHub Issue Forms (.github/ISSUE_TEMPLATE/) ---"
  TARGET_TPL_DIR="$(pwd)/.github/ISSUE_TEMPLATE"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] Would create $TARGET_TPL_DIR and copy YAML issue forms from $TEMPLATE_SRC_DIR"
  else
    mkdir -p "$TARGET_TPL_DIR"
    cp -f "$TEMPLATE_SRC_DIR/"*.yml "$TARGET_TPL_DIR/"
    echo "[OK] Installed Issue Forms into $TARGET_TPL_DIR:"
    ls -1 "$TARGET_TPL_DIR"
  fi
fi

echo ""
echo "[Bottega] GitHub Issues bootstrap complete."

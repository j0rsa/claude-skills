#!/usr/bin/env bash
# link_skill_locally.sh — symlink marketplace skills into ~/.claude/skills/
#
# Reads .claude-plugin/marketplace.json from the current working directory
# (expected to be the repo root), finds each registered skill, and creates
# a symlink in ~/.claude/skills/ so Claude Code loads skills directly from the
# checked-out source without reinstalling.
#
# Usage:
#   bash /path/to/link_skill_locally.sh [OPTIONS] [skill-name...]
#
# Options:
#   --force     Overwrite existing symlinks or directories at the target path.
#               WARNING: If the target is a real directory (not a symlink),
#               it will be deleted. Back up any in-progress local work first.
#   --dry-run   Print what would be done without creating or removing anything.
#   --flat      Always link directly under ~/.claude/skills/<skill-name>
#               (skip namespace folder even for multi-skill plugins).
#
# Arguments:
#   skill-name  One or more skill names to link (default: all skills in marketplace.json).
#
# Namespace detection:
#   - Single-skill plugin  → ~/.claude/skills/<skill-name>
#   - Multi-skill plugin   → ~/.claude/skills/<plugin-name>/<skill-name>
#   --flat overrides this and always uses the flat path.
#
# Examples:
#   bash link_skill_locally.sh
#   bash link_skill_locally.sh --force
#   bash link_skill_locally.sh punto
#   bash link_skill_locally.sh --force feedback-giver focus-area-composer
#   bash link_skill_locally.sh --flat --dry-run

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────

SKILLS_DIR="${HOME}/.claude/skills"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# ── Parse arguments ───────────────────────────────────────────────────────────

FORCE=false
DRY_RUN=false
FLAT=false
FILTER_SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --force)    FORCE=true ;;
    --dry-run)  DRY_RUN=true ;;
    --flat)     FLAT=true ;;
    --*)        echo "Error: unknown flag: $arg" >&2; exit 1 ;;
    *)          FILTER_SKILLS+=("$arg") ;;
  esac
done

# ── Validate environment ──────────────────────────────────────────────────────

REPO_ROOT="$(pwd)"

if [[ ! -f "${REPO_ROOT}/${MARKETPLACE_JSON}" ]]; then
  echo "Error: ${MARKETPLACE_JSON} not found in ${REPO_ROOT}" >&2
  echo "Run this script from the root of a marketplace repo." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required." >&2
  echo "  macOS:  brew install jq" >&2
  echo "  Linux:  apt install jq  (or equivalent)" >&2
  exit 1
fi

# ── Print run header ──────────────────────────────────────────────────────────

echo "Repo root  : ${REPO_ROOT}"
echo "Skills dir : ${SKILLS_DIR}"
if $DRY_RUN; then
  echo "Mode       : dry-run (no changes will be made)"
fi
if $FLAT; then
  echo "Layout     : flat (no namespace folders)"
fi
echo ""

# ── Process skills ────────────────────────────────────────────────────────────

linked=0
skipped=0
errors=0

while IFS=$'\t' read -r plugin_name skill_rel_path; do
  skill_name="$(basename "${skill_rel_path}")"

  # Apply optional skill name filter
  if [[ ${#FILTER_SKILLS[@]} -gt 0 ]]; then
    match=false
    for f in "${FILTER_SKILLS[@]}"; do
      [[ "$f" == "$skill_name" ]] && match=true && break
    done
    $match || continue
  fi

  # Absolute path to the skill folder in the repo
  source_path="${REPO_ROOT}/${skill_rel_path#./}"

  if [[ ! -d "$source_path" ]]; then
    echo "✗ [${plugin_name}/${skill_name}] source folder not found: ${source_path}" >&2
    errors=$((errors + 1))
    continue
  fi

  # ── Namespace detection ─────────────────────────────────────────────────────
  # Multi-skill plugins get a namespace folder: ~/.claude/skills/<plugin>/<skill>
  # Single-skill plugins go flat:               ~/.claude/skills/<skill>
  # --flat always uses the flat path.

  if ! $FLAT; then
    plugin_skill_count=$(jq --arg name "$plugin_name" \
      '[.plugins[] | select(.name == $name) | .skills[]] | length' \
      "${REPO_ROOT}/${MARKETPLACE_JSON}")
    if [[ "$plugin_skill_count" -gt 1 ]]; then
      target_path="${SKILLS_DIR}/${plugin_name}/${skill_name}"
    else
      target_path="${SKILLS_DIR}/${skill_name}"
    fi
  else
    target_path="${SKILLS_DIR}/${skill_name}"
  fi

  target_parent="$(dirname "$target_path")"

  # ── Report what we found ────────────────────────────────────────────────────

  echo "Skill : ${skill_name}  (plugin: ${plugin_name})"
  echo "  source → ${source_path}"
  echo "  target → ${target_path}"

  # ── Handle existing target ──────────────────────────────────────────────────

  if [[ -L "$target_path" ]]; then
    existing_dest="$(readlink "$target_path")"
    if [[ "$existing_dest" == "$source_path" ]]; then
      echo "  ✓ Already linked to the same source — skipping"
      skipped=$((skipped + 1))
      echo ""
      continue
    fi
    echo "  ! Existing symlink → ${existing_dest}"
    if $FORCE; then
      $DRY_RUN || rm "$target_path"
      echo "  ! Removed stale symlink"
    else
      echo "  ✗ Skipped — use --force to replace"
      skipped=$((skipped + 1))
      echo ""
      continue
    fi
  elif [[ -e "$target_path" ]]; then
    echo "  ! Existing directory (not a symlink)"
    if $FORCE; then
      echo "  WARNING: About to delete real directory: ${target_path}"
      $DRY_RUN || rm -rf "$target_path"
      echo "  ! Deleted"
    else
      echo "  ✗ Skipped — use --force to replace (WARNING: will delete the directory)"
      skipped=$((skipped + 1))
      echo ""
      continue
    fi
  fi

  # ── Create symlink ──────────────────────────────────────────────────────────

  if ! $DRY_RUN; then
    mkdir -p "$target_parent"
    ln -s "$source_path" "$target_path"
  fi
  echo "  ✓ Linked"
  linked=$((linked + 1))
  echo ""

done < <(jq -r '.plugins[] | .name as $p | .skills[] | [$p, .] | @tsv' \
           "${REPO_ROOT}/${MARKETPLACE_JSON}")

# ── Summary ───────────────────────────────────────────────────────────────────

echo "────────────────────────────────────────────"
echo "  Linked  : ${linked}"
echo "  Skipped : ${skipped}"
echo "  Errors  : ${errors}"

if [[ $errors -gt 0 ]]; then
  exit 1
fi

#!/usr/bin/env bash
# link_skill_locally.sh — symlink marketplace plugin skills into ~/.claude/skills/
#
# Reads .claude-plugin/marketplace.json from the current working directory
# (expected to be the repo root), resolves each plugin's source path, discovers
# skill directories under <plugin-source>/skills/, and creates symlinks at
# ~/.claude/skills/<plugin-name>/<skill-name> so Claude Code loads skills
# directly from the checked-out source without reinstalling.
#
# Usage:
#   bash /path/to/link_skill_locally.sh [OPTIONS] [skill-name...]
#
# Options:
#   --force     Overwrite existing symlinks or directories at the target path.
#               WARNING: If the target is a real directory (not a symlink),
#               it will be deleted. Back up any in-progress local work first.
#   --dry-run   Print what would be done without creating or removing anything.
#
# Arguments:
#   skill-name  One or more skill names to link (default: all skills in all plugins).
#
# All skills are linked under their plugin namespace:
#   ~/.claude/skills/<plugin-name>/<skill-name>
#
# Examples:
#   bash link_skill_locally.sh
#   bash link_skill_locally.sh --force
#   bash link_skill_locally.sh punto
#   bash link_skill_locally.sh --force skill-a skill-b

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────

SKILLS_DIR="${HOME}/.claude/skills"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# ── Parse arguments ───────────────────────────────────────────────────────────

FORCE=false
DRY_RUN=false
FILTER_SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --force)    FORCE=true ;;
    --dry-run)  DRY_RUN=true ;;
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
echo ""

# ── Process skills ────────────────────────────────────────────────────────────

linked=0
skipped=0
errors=0

# Read each plugin name and source path from marketplace.json, then discover
# skills by scanning the plugin's skills/ subdirectory.
while IFS=$'\t' read -r plugin_name plugin_source; do
  plugin_dir="${REPO_ROOT}/${plugin_source#./}"
  skills_dir="${plugin_dir}/skills"

  if [[ ! -d "$skills_dir" ]]; then
    continue
  fi

  while IFS= read -r -d '' skill_dir; do
    skill_name="$(basename "$skill_dir")"
    source_path="$skill_dir"

    # Apply optional skill name filter
    if [[ ${#FILTER_SKILLS[@]} -gt 0 ]]; then
      match=false
      for f in "${FILTER_SKILLS[@]}"; do
        [[ "$f" == "$skill_name" ]] && match=true && break
      done
      $match || continue
    fi

    # Always namespaced: ~/.claude/skills/<plugin-name>/<skill-name>
    target_path="${SKILLS_DIR}/${plugin_name}/${skill_name}"
    target_parent="$(dirname "$target_path")"

    # ── Report what we found ───────────────────────────────────────────

    echo "Skill : ${skill_name}  (plugin: ${plugin_name})"
    echo "  source → ${source_path}"
    echo "  target → ${target_path}"

    # ── Handle existing target ───────────────────────────────────────

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

    # ── Create symlink ─────────────────────────────────────────────────

    if ! $DRY_RUN; then
      mkdir -p "$target_parent"
      ln -s "$source_path" "$target_path"
    fi
    echo "  ✓ Linked"
    linked=$((linked + 1))
    echo ""

  done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

done < <(jq -r '.plugins[] | [.name, .source] | @tsv' \
           "${REPO_ROOT}/${MARKETPLACE_JSON}")

# ── Summary ───────────────────────────────────────────────────────────────────

echo "────────────────────────────────────────────"
echo "  Linked  : ${linked}"
echo "  Skipped : ${skipped}"
echo "  Errors  : ${errors}"

if [[ $errors -gt 0 ]]; then
  exit 1
fi

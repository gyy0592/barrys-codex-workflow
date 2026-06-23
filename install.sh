#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  ./install.sh
  curl -fsSL <raw-install.sh-url> | bash -s -- <repo-url>

Environment:
  CODEX_HOME                 Codex home directory. Default: ~/.codex
  CODEX_WORKFLOW_REPO_URL    Repo URL used when this script is run outside a checkout.
  CODEX_WORKFLOW_INSTALL_DIR Checkout directory for remote install. Default: ~/.codex/source/codex_workflow_tmux
EOF
}

repo_ref=${CODEX_WORKFLOW_REPO_URL:-}
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -n "$repo_ref" ]; then
        printf 'unexpected extra argument: %s\n' "$1" >&2
        usage
        exit 2
      fi
      repo_ref=$1
      ;;
  esac
  shift
done

source_path=${BASH_SOURCE[0]:-$0}
script_dir=
if [ -n "$source_path" ] && [ -e "$source_path" ]; then
  script_dir=$(CDPATH= cd -- "$(dirname -- "$source_path")" && pwd)
fi

is_checkout() {
  local dir=$1
  test -f "$dir/SKILL.md" &&
    test -x "$dir/scripts/install_skill.sh" &&
    test -f "$dir/templates/short_goal_message.md" &&
    test -f "$dir/skills/workflow-error-transition/SKILL.md"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$1" >&2
    return 1
  fi
}

missing_required=0
require_command git || missing_required=1
require_command tmux || missing_required=1
if [ "$missing_required" -ne 0 ]; then
  printf 'Install git and tmux before installing this workflow.\n' >&2
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  printf 'warning: Codex CLI was not found; install it before using the tmux supervisor workflow.\n' >&2
fi

if [ -n "$script_dir" ] && is_checkout "$script_dir"; then
  repo_dir=$script_dir
else
  if [ -z "$repo_ref" ]; then
    printf 'repo URL is required when install.sh is not run from a checkout\n' >&2
    usage
    exit 2
  fi

  repo_dir=${CODEX_WORKFLOW_INSTALL_DIR:-"$HOME/.codex/source/codex_workflow_tmux"}
  if [ -d "$repo_dir/.git" ]; then
    if git -C "$repo_dir" remote get-url origin >/dev/null 2>&1; then
      git -C "$repo_dir" pull --ff-only
    else
      printf 'Using existing checkout without remote: %s\n' "$repo_dir" >&2
    fi
  elif [ -e "$repo_dir" ]; then
    printf 'install directory exists but is not a git checkout: %s\n' "$repo_dir" >&2
    exit 1
  else
    mkdir -p "$(dirname -- "$repo_dir")"
    git clone "$repo_ref" "$repo_dir"
  fi

  if ! is_checkout "$repo_dir"; then
    printf 'cloned repo is missing required workflow files: %s\n' "$repo_dir" >&2
    exit 1
  fi
fi

"$repo_dir/scripts/install_skill.sh"

codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill_dir="$codex_home/skills/tmux-codex-supervisor"
error_skill_dir="$codex_home/skills/workflow-error-transition"
test -f "$skill_dir/SKILL.md"
test -f "$skill_dir/templates/short_goal_message.md"
test -x "$skill_dir/scripts/inject_steer.sh"
test -x "$skill_dir/scripts/locate_codex.sh"
test -f "$error_skill_dir/SKILL.md"
grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$codex_home/AGENTS.md" >/dev/null

printf 'ONE_CLICK_INSTALL_OK %s\n' "$skill_dir"

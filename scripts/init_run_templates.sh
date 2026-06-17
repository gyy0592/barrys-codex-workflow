#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <task-directory> <workflow-id> [spec-name ...]\n' "$0" >&2
}

if [ "$#" -lt 2 ]; then
  usage
  exit 64
fi

task_dir=$1
workflow_id=$2
shift 2

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)

case "$workflow_id" in
  workflow_*) workflow_dir="$task_dir/$workflow_id" ;;
  *) workflow_dir="$task_dir/workflow_$workflow_id" ;;
esac

copy_if_missing() {
  local template=$1
  local dest=$2
  local src="$repo_dir/templates/$template"

  if [ ! -f "$src" ]; then
    printf 'MISSING_TEMPLATE %s\n' "$src" >&2
    exit 66
  fi

  mkdir -p "$(dirname -- "$dest")"
  if [ -e "$dest" ]; then
    printf 'EXISTS %s\n' "$dest"
    return 0
  fi

  cp "$src" "$dest"
  printf 'CREATED %s\n' "$dest"
}

copy_if_missing goal.md "$task_dir/control/goal.md"
copy_if_missing constraint.md "$task_dir/control/constraint.md"
copy_if_missing run_goal.md "$workflow_dir/run_goal.md"
copy_if_missing specs.md "$workflow_dir/specs.md"

for spec_name in "$@"; do
  case "$spec_name" in
    spec_*) spec_dir="$workflow_dir/$spec_name" ;;
    *) spec_dir="$workflow_dir/spec_$spec_name" ;;
  esac

  copy_if_missing spec_status.md "$spec_dir/status.md"
  copy_if_missing source_discovery.md "$spec_dir/source_discovery.md"
  copy_if_missing abstract_plan.md "$spec_dir/abstract_plan.md"
  copy_if_missing evidence.md "$spec_dir/evidence.md"
  copy_if_missing review.md "$spec_dir/review.md"
  copy_if_missing bitter_lesson.md "$spec_dir/bitter_lesson.md"
done

printf 'RUN_TEMPLATES_READY %s\n' "$workflow_dir"

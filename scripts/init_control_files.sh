#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <task-directory>\n' "$0" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 64
fi

task_dir=$1
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
control_dir="$task_dir/control"

mkdir -p "$control_dir"

for name in goal.md constraint.md; do
  src="$repo_dir/templates/$name"
  dest="$control_dir/$name"
  if [ ! -f "$src" ]; then
    printf 'Missing template: %s\n' "$src" >&2
    exit 66
  fi
  if [ -e "$dest" ]; then
    printf 'Refusing to overwrite existing file: %s\n' "$dest" >&2
    exit 73
  fi
  cp "$src" "$dest"
done

printf 'CONTROL_FILES_CREATED %s\n' "$control_dir"


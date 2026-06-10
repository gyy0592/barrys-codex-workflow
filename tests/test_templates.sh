#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

"$repo_dir/scripts/init_control_files.sh" "$tmp_dir/task"

test -f "$tmp_dir/task/control/goal.md"
test -f "$tmp_dir/task/control/constraint.md"
test ! -e "$tmp_dir/task/control/self_check.md"
test ! -e "$tmp_dir/task/control/progress.md"
test ! -e "$tmp_dir/task/control/done.md"

grep -F 'control/goal.md' "$repo_dir/templates/short_goal_message.md" >/dev/null
grep -F 'control/constraint.md' "$repo_dir/templates/short_goal_message.md" >/dev/null
if grep -F -e 'control/self_check.md' -e 'control/progress.md' -e 'control/done.md' "$repo_dir/templates/short_goal_message.md" >/dev/null; then
  printf 'short_goal_message.md references extra control files\n' >&2
  exit 1
fi

printf 'test_templates PASS\n'


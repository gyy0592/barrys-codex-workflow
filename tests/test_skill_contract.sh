#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skill_file="$repo_dir/SKILL.md"

test -f "$skill_file"

grep -F 'description: "' "$skill_file" >/dev/null
grep -F 'control/goal.md' "$skill_file" >/dev/null
grep -F 'control/constraint.md' "$skill_file" >/dev/null
grep -F 'scripts/send_tmux_message.sh' "$skill_file" >/dev/null
grep -F 'scripts/capture_tmux_screen.sh' "$skill_file" >/dev/null
grep -F 'scripts/verify_delivery.sh' "$skill_file" >/dev/null

if grep -F -e 'control/self_check.md' -e 'control/progress.md' -e 'control/done.md' "$skill_file" >/dev/null; then
  printf 'SKILL.md references extra control files\n' >&2
  exit 1
fi

printf 'test_skill_contract PASS\n'


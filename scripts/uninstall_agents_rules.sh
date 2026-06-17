#!/usr/bin/env bash
set -euo pipefail

codex_home=${CODEX_HOME:-"$HOME/.codex"}
agents_file="$codex_home/AGENTS.md"
begin_marker='<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN -->'
end_marker='<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_END -->'

if [ ! -f "$agents_file" ]; then
  printf 'AGENTS_SUBAGENT_RULES_NOT_FOUND %s\n' "$agents_file"
  exit 0
fi

tmp_file=$(mktemp)
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

awk -v begin="$begin_marker" -v end="$end_marker" '
  $0 == begin { found = 1; skip = 1; next }
  $0 == end { skip = 0; next }
  skip != 1 { print }
  END { if (found != 1) exit 3 }
' "$agents_file" > "$tmp_file" || status=$?

status=${status:-0}
if [ "$status" -eq 3 ]; then
  printf 'AGENTS_SUBAGENT_RULES_NOT_FOUND %s\n' "$agents_file"
  exit 0
elif [ "$status" -ne 0 ]; then
  exit "$status"
fi

cp "$tmp_file" "$agents_file"
printf 'AGENTS_SUBAGENT_RULES_REMOVED %s\n' "$agents_file"

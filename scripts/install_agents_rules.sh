#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_home=${CODEX_HOME:-"$HOME/.codex"}
agents_file="$codex_home/AGENTS.md"
template_file="$repo_dir/templates/agents_subagent_rules.md"
begin_marker='<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN -->'
end_marker='<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_END -->'

test -f "$template_file"
mkdir -p "$codex_home"
touch "$agents_file"

tmp_file=$(mktemp)
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

awk -v begin="$begin_marker" -v end="$end_marker" '
  $0 == begin { skip = 1; next }
  $0 == end { skip = 0; next }
  skip != 1 { print }
' "$agents_file" > "$tmp_file"

cp "$tmp_file" "$agents_file"
if [ -s "$agents_file" ]; then
  printf '\n' >> "$agents_file"
fi
cat "$template_file" >> "$agents_file"
printf '\n' >> "$agents_file"

printf 'AGENTS_SUBAGENT_RULES_INSTALLED %s\n' "$agents_file"

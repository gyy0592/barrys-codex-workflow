#!/usr/bin/env bash
#
# locate_codex.sh -- read-only tmux pane discovery aid for tmux-codex-supervisor.
#
# Lists tmux panes that look like a live Codex TUI so a supervisor can confirm
# the exact <session:window.pane> target before sending controlled Codex input.
#
# Strictly read-only: no tmux state is mutated, no files are written.
#
# Usage: locate_codex.sh
#
# Env:
#   STEER_CMD_ALLOWLIST   regex of process names treated as Codex (default: codex)

set -uo pipefail

CMD_ALLOWLIST="${STEER_CMD_ALLOWLIST:-codex}"

echo "== Candidate tmux panes =="
if ! tmux info >/dev/null 2>&1; then
  echo "  (no tmux server running)"
else
  fmt='#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{alternate_on}|#{pane_in_mode}|#{pane_dead}|#{pane_tty}|#{pane_current_path}'
  tmux list-panes -a -F "$fmt" 2>/dev/null | while IFS='|' read -r target cmd alt inmode dead tty cwd; do
    live="-"
    [ "$dead" = "0" ] && [ "$inmode" = "0" ] && live="live"

    hint="-"
    if printf '%s' "$cmd" | grep -qiE "$CMD_ALLOWLIST"; then
      hint="codex?"
    else
      t="${tty#/dev/}"
      if [ -n "$t" ] && ps -t "$t" -o args= 2>/dev/null | grep -qiE "$CMD_ALLOWLIST"; then
        hint="codex?"
      fi
    fi

    [ "$hint" = "codex?" ] && [ "$live" = "live" ] || continue
    printf '  %-24s cmd=%-12s [%s %s]\n      cwd=%s\n' \
      "$target" "$cmd" "$live" "$hint" "$cwd"
  done
fi

echo
echo "Pick the pane whose cwd matches the supervised task, then use that <session:window.pane> as the tmux target."

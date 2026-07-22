#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <tmux-pane> <message-file>" >&2
  exit 64
fi

pane="$1"
message_file="$2"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
inject="${INJECT_STEER_SH:-$script_dir/inject_steer.sh}"
evidence_dir="${STEER_EVIDENCE_DIR:-./temp/tmux-codex-supervisor/force-interrupt-send-resume}"
mkdir -p "$evidence_dir"

resume_file="$(mktemp "$evidence_dir/goal-resume.XXXXXX.txt")"
stop_file="$(mktemp "$evidence_dir/stop-background.XXXXXX.txt")"
printf '/goal resume\n' > "$resume_file"
printf '/stop\n' > "$stop_file"

"$inject" verify-target "$pane" >/dev/null

tmux capture-pane -p -J -t "$pane" > "$evidence_dir/before-escape.txt" 2>/dev/null || true

paused=0
if grep -Eq 'Goal paused \(/goal resume\)|Conversation interrupted|Goal paused' "$evidence_dir/before-escape.txt"; then
  paused=1
else
  tmux send-keys -t "$pane" Escape
  for _ in $(seq 1 80); do
    tmux capture-pane -p -J -t "$pane" > "$evidence_dir/after-escape-poll.txt" 2>/dev/null || true
    if grep -Eq 'Goal paused \(/goal resume\)|Conversation interrupted|Goal paused' "$evidence_dir/after-escape-poll.txt"; then
      paused=1
      break
    fi
    sleep 0.25
  done
fi

if [ "$paused" -ne 1 ]; then
  echo "force-send failed: Escape did not produce a visible paused/interrupted goal state" >&2
  exit 20
fi

tmux capture-pane -p -J -t "$pane" > "$evidence_dir/before-stop.txt" 2>/dev/null || true
if tail -n 30 "$evidence_dir/before-stop.txt" | grep -q 'background terminal running'; then
  STEER_EVIDENCE_DIR="$evidence_dir/send-stop" "$inject" send "$pane" "$stop_file"
  for _ in $(seq 1 80); do
    tmux capture-pane -p -J -t "$pane" > "$evidence_dir/after-stop-poll.txt" 2>/dev/null || true
    if ! tail -n 30 "$evidence_dir/after-stop-poll.txt" | grep -q 'background terminal running'; then
      break
    fi
    sleep 0.25
  done
fi

STEER_EVIDENCE_DIR="$evidence_dir/send-message" "$inject" send "$pane" "$message_file"
sleep 0.5
STEER_EVIDENCE_DIR="$evidence_dir/send-resume" "$inject" send "$pane" "$resume_file"

resumed=0
for _ in $(seq 1 160); do
  tmux capture-pane -p -J -t "$pane" > "$evidence_dir/after-resume-poll.txt" 2>/dev/null || true
  if grep -q 'Pursuing goal' "$evidence_dir/after-resume-poll.txt" && ! tail -n 20 "$evidence_dir/after-resume-poll.txt" | grep -q 'Goal paused (/goal resume)'; then
    resumed=1
    break
  fi
  sleep 0.25
done

if [ "$resumed" -ne 1 ]; then
  echo "force-send failed: /goal resume did not return the pane to Pursuing goal" >&2
  exit 21
fi

echo "force-send ok: interrupted, sent message, resumed goal"

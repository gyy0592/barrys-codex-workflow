#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
session="cwft_test_$$"
target="$session:0"

cleanup() {
  tmux kill-session -t "$session" 2>/dev/null || true
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

tmux new-session -d -s "$session" -c "$tmp_dir" bash --noprofile --norc

marker="TASK_RECEIVED_$session"
message_file="$tmp_dir/message.txt"
printf "printf '%s\\n'\n" "$marker" > "$message_file"

STEER_REQUIRE_CODEX=0 STEER_EVIDENCE_DIR="$tmp_dir/evidence" \
  "$repo_dir/scripts/inject_steer.sh" send "$target" "$message_file" >/dev/null
tmux capture-pane -p -t "$target" -S -80 | grep -F "$marker" >/dev/null

progress_file="$tmp_dir/progress.txt"
state_file="$tmp_dir/state/progress.sha256"
printf 'step one\n' > "$progress_file"
"$repo_dir/scripts/check_progress.sh" "$progress_file" "$state_file" >/dev/null

set +e
"$repo_dir/scripts/check_progress.sh" "$progress_file" "$state_file" >"$tmp_dir/check_progress_second.out" 2>"$tmp_dir/check_progress_second.err"
unchanged_status=$?
set -e
if [ "$unchanged_status" -ne 2 ]; then
  printf 'Expected unchanged progress exit 2, got %s\n' "$unchanged_status" >&2
  exit 1
fi

printf 'step two\n' >> "$progress_file"
"$repo_dir/scripts/check_progress.sh" "$progress_file" "$state_file" >/dev/null

"$repo_dir/scripts/check_done.sh" test -s "$progress_file" >/dev/null
set +e
"$repo_dir/scripts/check_done.sh" test -s "$tmp_dir/missing.txt" >"$tmp_dir/check_done_fail.out" 2>"$tmp_dir/check_done_fail.err"
done_status=$?
set -e
if [ "$done_status" -eq 0 ]; then
  printf 'Expected check_done failure for missing file\n' >&2
  exit 1
fi

archive="$tmp_dir/output.tar.gz"
(cd "$tmp_dir" && "$repo_dir/scripts/package_outputs.sh" "$archive" progress.txt >/dev/null)
tar -tzf "$archive" | grep -F 'progress.txt' >/dev/null

printf 'test_tmux_scripts PASS\n'

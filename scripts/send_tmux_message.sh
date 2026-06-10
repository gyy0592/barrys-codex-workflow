#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <tmux-target> <message-file> [--escape-after-enter]\n' "$0" >&2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage
  exit 64
fi

target=$1
message_file=$2
escape_after_enter=${3:-}

if [ "$escape_after_enter" != "" ] && [ "$escape_after_enter" != "--escape-after-enter" ]; then
  usage
  exit 64
fi

if [ ! -r "$message_file" ]; then
  printf 'Message file is not readable: %s\n' "$message_file" >&2
  exit 66
fi

tmux display-message -p -t "$target" '#{pane_id}' >/dev/null

buffer_name="codex_workflow_tmux_$$"
cleanup() {
  tmux delete-buffer -b "$buffer_name" 2>/dev/null || true
}
trap cleanup EXIT

tmux load-buffer -b "$buffer_name" "$message_file"
tmux paste-buffer -t "$target" -b "$buffer_name"
tmux send-keys -t "$target" Enter

if [ "$escape_after_enter" = "--escape-after-enter" ]; then
  tmux send-keys -t "$target" Escape
fi

printf 'MESSAGE_SENT target=%s file=%s\n' "$target" "$message_file"


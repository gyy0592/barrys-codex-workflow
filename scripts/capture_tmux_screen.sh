#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <tmux-target> [line-count]\n' "$0" >&2
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  usage
  exit 64
fi

target=$1
line_count=${2:-120}

case "$line_count" in
  ''|*[!0-9]*)
    printf 'Line count must be a positive integer.\n' >&2
    exit 64
    ;;
esac

if [ "$line_count" -eq 0 ]; then
  printf 'Line count must be greater than zero.\n' >&2
  exit 64
fi

tmux capture-pane -p -t "$target" -S "-$line_count"


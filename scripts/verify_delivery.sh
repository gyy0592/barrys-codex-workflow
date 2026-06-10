#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <tmux-target> <expected-text> [timeout-seconds]\n' "$0" >&2
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage
  exit 64
fi

target=$1
expected=$2
timeout=${3:-10}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

case "$timeout" in
  ''|*[!0-9]*)
    printf 'Timeout must be a non-negative integer.\n' >&2
    exit 64
    ;;
esac

end=$((SECONDS + timeout))
while [ "$SECONDS" -le "$end" ]; do
  if "$script_dir/capture_tmux_screen.sh" "$target" 120 | grep -F -- "$expected" >/dev/null; then
    printf 'DELIVERED target=%s expected=%s\n' "$target" "$expected"
    exit 0
  fi
  sleep 1
done

printf 'NOT_DELIVERED target=%s expected=%s\n' "$target" "$expected" >&2
exit 1


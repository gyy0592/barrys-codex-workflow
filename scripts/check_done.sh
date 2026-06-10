#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <completion-check-command> [args...]\n' "$0" >&2
}

if [ "$#" -lt 1 ]; then
  usage
  exit 64
fi

output_file=$(mktemp)
cleanup() {
  rm -f "$output_file"
}
trap cleanup EXIT

set +e
"$@" >"$output_file" 2>&1
status=$?
set -e

if [ "$status" -eq 0 ]; then
  printf 'DONE_PASS command='
  printf '%q ' "$@"
  printf '\n'
  cat "$output_file"
  exit 0
fi

printf 'DONE_FAIL exit_code=%s command=' "$status" >&2
printf '%q ' "$@" >&2
printf '\n' >&2
cat "$output_file" >&2
exit 1


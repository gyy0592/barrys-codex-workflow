#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <progress-evidence-file> <state-file>\n' "$0" >&2
}

if [ "$#" -ne 2 ]; then
  usage
  exit 64
fi

evidence_file=$1
state_file=$2

if [ ! -f "$evidence_file" ]; then
  printf 'PROGRESS_MISSING file=%s\n' "$evidence_file" >&2
  exit 3
fi

current_hash=$(sha256sum "$evidence_file" | awk '{print $1}')
previous_hash=""
if [ -f "$state_file" ]; then
  previous_hash=$(sed -n '1p' "$state_file")
fi

if [ "$current_hash" = "$previous_hash" ]; then
  printf 'PROGRESS_UNCHANGED file=%s\n' "$evidence_file" >&2
  exit 2
fi

mkdir -p "$(dirname -- "$state_file")"
printf '%s\n' "$current_hash" > "$state_file"
printf 'PROGRESS_CHANGED file=%s\n' "$evidence_file"


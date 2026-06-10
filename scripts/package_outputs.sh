#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <output-tar.gz> <path> [path...]\n' "$0" >&2
}

if [ "$#" -lt 2 ]; then
  usage
  exit 64
fi

archive=$1
shift

for path in "$@"; do
  if [ ! -e "$path" ]; then
    printf 'Output path does not exist: %s\n' "$path" >&2
    exit 66
  fi
done

tar -czf "$archive" "$@"
printf 'PACKAGED archive=%s paths=%s\n' "$archive" "$*"


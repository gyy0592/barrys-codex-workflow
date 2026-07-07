#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

require() {
  local needle=$1
  local file=$2
  grep -F "$needle" "$file" >/dev/null
}

reject() {
  local needle=$1
  local file=$2
  if grep -F "$needle" "$file" >/dev/null; then
    printf 'unexpected tutorial text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

for doc in "$repo_dir/README.md" "$repo_dir/docs/usage.md"; do
  require 'run-file-writer' "$doc"
  require 'requirement_dialogue.md' "$doc"
  require 'prompt_for_supervisor_goal.md' "$doc"
  require 'codex --dangerously-bypass-approvals-and-sandbox' "$doc"
  require 'Do not start the run.' "$doc"
  reject 'tmux new -s codex-supervisor' "$doc"

  reject 'user reviews these files before execution' "$doc"
  reject 'Execute After User Approval' "$doc"
  reject 'After the user approves' "$doc"
  reject 'user approval step' "$doc"
  reject 'Create and fill control/goal.md and control/constraint.md.' "$doc"
  reject 'separate execution request' "$doc"
  reject 'This request enters the execution phase.' "$doc"
  reject 'fix run files if needed' "$doc"
  reject 'The controlled Codex still receives' "$doc"
  reject 'That controlled-Codex message is exactly' "$doc"
  reject 'controlled Codex' "$doc"
  reject 'controlled-Codex' "$doc"
done

require '[中文](README.zh.md) | English' "$repo_dir/README.md"
require '中文 | [English](README.md)' "$repo_dir/README.zh.md"
require './install.sh' "$repo_dir/README.md"
require './install.sh' "$repo_dir/docs/usage.md"
require 'Use the run-file-writer skill.' "$repo_dir/docs/usage.md"
require 'Generate final run files only.' "$repo_dir/docs/usage.md"
require 'Type `/goal`.' "$repo_dir/docs/usage.md"

printf 'test_docs PASS\n'

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
  require 'no second execution approval' "$doc"
  require 'codex --dangerously-bypass-approvals-and-sandbox' "$doc"

  reject 'user reviews these files before execution' "$doc"
  reject 'Execute After User Approval' "$doc"
  reject 'After the user approves' "$doc"
  reject 'user approval step' "$doc"
  reject 'Create and fill control/goal.md and control/constraint.md.' "$doc"
  reject 'separate execution request' "$doc"
  reject 'This request enters the execution phase.' "$doc"
  reject 'fix run files if needed' "$doc"
done

require 'short /goal message' "$repo_dir/README.md"
require './install.sh' "$repo_dir/README.md"
require 'curl -fsSL <raw-install.sh-url> | bash -s -- <repo-url>' "$repo_dir/README.md"
require 'short `/goal` message' "$repo_dir/docs/usage.md"
require './install.sh' "$repo_dir/docs/usage.md"
require 'curl -fsSL <raw-install.sh-url> | bash -s -- <repo-url>' "$repo_dir/docs/usage.md"
require 'Use the run-file-writer skill.' "$repo_dir/docs/usage.md"
require 'Generate final run files only.' "$repo_dir/docs/usage.md"
require 'Do not start the controlled Codex.' "$repo_dir/docs/usage.md"
require 'the user types `/goal` in Codex and pastes the text' "$repo_dir/docs/usage.md"
require 'must not be included in the template' "$repo_dir/docs/usage.md"

printf 'test_docs PASS\n'

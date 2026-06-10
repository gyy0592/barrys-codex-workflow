#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

"$repo_dir/tests/test_templates.sh"
"$repo_dir/tests/test_tmux_scripts.sh"

printf 'ALL_TESTS_PASS\n'


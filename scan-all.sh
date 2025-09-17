#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-packages.sh"

for dir in "$BASE_DIR"/*/ ; do
  [ -d "$dir" ] || continue
  [ -f "$dir/package.json" ] || continue

  repo_name="$(basename "$dir")"
  echo "=== $repo_name ==="

  (
    cd "$dir"
    "$CHECK_SCRIPT"
  )
  echo
done

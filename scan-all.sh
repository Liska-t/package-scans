#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check-packages.sh"
PACKAGES_FILE="$SCRIPT_DIR/packages.txt"

echo "Opening one Terminal window per repo under: $BASE_DIR"

for dir in "$BASE_DIR"/*/ ; do
  [ -d "$dir" ] || continue
  [ -f "$dir/package.json" ] || continue

  repo_name="$(basename "$dir")"
  echo "→ $repo_name"

  /usr/bin/osascript <<EOF
tell application "Terminal"
  do script "cd " & quoted form of POSIX path of POSIX file "$dir" ¬
           & " && " & quoted form of POSIX path of POSIX file "$CHECK_SCRIPT" ¬
           & " " & quoted form of POSIX path of POSIX file "$PACKAGES_FILE" ¬
           & "; echo; echo '[$repo_name] done'; exec \$SHELL -l"
  activate
end tell
EOF
done


## OG script runs all sequentially

##!/usr/bin/env bash
#set -euo pipefail
#
#BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
#CHECK_SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-packages.sh"
#
#for dir in "$BASE_DIR"/*/ ; do
#  [ -d "$dir" ] || continue
#  [ -f "$dir/package.json" ] || continue
#
#  repo_name="$(basename "$dir")"
#  echo "=== $repo_name ==="
#
#  (
#    cd "$dir"
#    "$CHECK_SCRIPT"
#  )
#  echo
#done
#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_FILE="${1:-$SCRIPT_DIR/packages.txt}"

echo "Checking for listed packages from: $PKG_FILE"
echo "------------------------------------------------"

if [ ! -f "$PKG_FILE" ]; then
  echo "Packages file not found: $PKG_FILE" >&2
  exit 1
fi

TOTAL=$(grep -Evc '^[[:space:]]*(#|$)' "$PKG_FILE" || true)
COUNT=0
FOUND_DEPS=""

check_package() {
  package=$1
  version=$2

  COUNT=$((COUNT+1))
  if [ "$TOTAL" -gt 0 ]; then
    PERCENT=$((COUNT * 100 / TOTAL))
  else
    PERCENT=0
  fi
  printf "\r[%3d%%] Checking: %s (target %s)" "$PERCENT" "$package" "$version"

  installed_versions="$(
    npm ls "$package" --all --depth=Infinity 2>/dev/null \
      | grep -F "$package@" \
      | awk -F'@' '{print $NF}' \
      | sort -u
  )"

  if [ -n "$installed_versions" ]; then
    FOUND_DEPS="$FOUND_DEPS\n$package@$version -> installed: $(printf '%s' "$installed_versions" | tr '\n' ' ')"
  fi

  if [ "$TOTAL" -gt 0 ] && [ "$COUNT" -eq "$TOTAL" ]; then
    echo
  fi
}

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  version="${line##*@}"
  name="${line%@$version}"
  [ "$name" = "$line" ] && continue
  check_package "$name" "$version"
done < "$PKG_FILE"

echo "------------------------------------------------"
if [ -n "$FOUND_DEPS" ]; then
  echo "✅ Found dependencies:"
  printf "%b\n" "$FOUND_DEPS"
else
  echo "❌ No dependency found"
fi
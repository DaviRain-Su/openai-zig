#!/usr/bin/env bash
set -euo pipefail

IR_PATH="generated/ir.json"
RESOURCES_GLOB="src/resources/*.zig"

if [ ! -f "$IR_PATH" ]; then
  echo "missing: $IR_PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "missing dependency: jq" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "missing dependency: rg" >&2
  exit 1
fi

TMP_METHODS=$(mktemp)
trap 'rm -f "$TMP_METHODS"' EXIT

while IFS= read -r line; do
  if [[ "$line" =~ pub[[:space:]]+fn[[:space:]]+([A-Za-z_][A-Za-z0-9_]*) ]]; then
    name="${BASH_REMATCH[1]}"
    echo "$name" >> "$TMP_METHODS"
  fi
done < <(rg --no-filename 'pub fn [A-Za-z_][A-Za-z0-9_]*' $RESOURCES_GLOB)
sort -u "$TMP_METHODS" -o "$TMP_METHODS"

to_snake() {
  printf '%s' "$1" | perl -pe 's/([a-z0-9])([A-Z])/$1_$2/g; s/([A-Z]+)([A-Z][a-z])/$1_$2/g; s/-/_/g; y/A-Z/a-z/'
}

missing=0
while IFS= read -r id; do
  snake="$(to_snake "$id")"
  if ! grep -qx "$snake" "$TMP_METHODS"; then
    printf '%s\t%s\n' "$id" "$snake"
    ((missing += 1))
  fi
done < <(jq -r '.operations[].id' "$IR_PATH")

if [ "$missing" -ne 0 ]; then
  echo "missing operation wrappers: $missing" >&2
  exit 1
fi

echo "all operation wrappers present"

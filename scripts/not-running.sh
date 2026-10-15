#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:?usage: $0 <pods.json>}"    # first argument is required; fail with a usage hint if missing

# Read jq output line by line into an array.
# Works on bash 3.2 (macOS) too, where 'mapfile' is not available.
pods=()
while IFS= read -r name; do            # IFS= and -r keep each line exactly as is (no trimming, no backslash escapes)
  pods+=("$name")
done < <(jq -r '.items[] | select(.status.phase != "Running") | .metadata.name' "$INPUT")
# '< <(cmd)' feeds the loop from cmd's output without a subshell, so 'pods' stays visible after the loop

if [[ ${#pods[@]} -eq 0 ]]; then
  echo "all pods are Running"
  exit 0
fi

echo "not running: ${#pods[@]}"
for p in "${pods[@]}"; do
  echo "would run: kubectl describe pod $p"
done

# Safe access to a field that may be missing: '// empty' turns null into no output
reason=$(jq -r '.items[0].status.reason // empty' "$INPUT")
echo "reason of first pod: '${reason:-<none>}'"   # fall back to <none> in bash if jq printed nothing
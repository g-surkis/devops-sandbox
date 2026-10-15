#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-g-surkis/devops-sandbox}"   # owner/repo; defaults to the sandbox

# Public repo: no token needed (unauthenticated limit is 60 requests/hour).
# In GitHub Actions you would add: -H "Authorization: Bearer $GITHUB_TOKEN"
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases")
# -f: fail on HTTP errors (e.g. 404) instead of passing the error page to jq
# -sS: no progress bar, but still show errors; -L: follow redirects

tags=()
while IFS= read -r t; do
  tags+=("$t")
done < <(jq -r '.[].tag_name' <<< "$json")   # API returns newest release first

if [[ ${#tags[@]} -eq 0 ]]; then
  echo "no releases in $REPO" >&2   # >&2 sends the message to stderr, keeping stdout clean for machine use
  exit 1
fi

echo "releases: ${#tags[@]}"
echo "all: ${tags[*]}"           # [*] joins into one string, fine for display
echo "latest: ${tags[0]}"
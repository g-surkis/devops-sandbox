#!/usr/bin/env bash
set -euo pipefail

# Declare an array; one element contains a space on purpose
services=("gpu-lb" "ultraform-api" "my service")

echo "count: ${#services[@]}"          # number of elements
echo "first: ${services[0]}"           # access by index

echo "--- correct: \"\${services[@]}\" keeps each element intact"
for s in "${services[@]}"; do
  echo "  [$s]"
done

echo "--- wrong: unquoted \${services[@]} splits on spaces"
# shellcheck disable=SC2068   # intentional bug for the demo; shellcheck would flag it otherwise
for s in ${services[@]}; do
  echo "  [$s]"
done

services+=("worker")                   # append an element
echo "after append: ${#services[@]} elements"

echo "--- GitHub releases"
repo="g-surkis/devops-sandbox"
api_url="https://api.github.com/repos/${repo}/releases"
release_tags=()
page=1

curl_args=(
  --fail
  --silent
  --show-error
  --header "Accept: application/vnd.github+json"
  --header "X-GitHub-Api-Version: 2022-11-28"
)
if [[ -n "${GH_TOKEN:-}" ]]; then
  curl_args+=(--header "Authorization: Bearer ${GH_TOKEN}")
fi

while true; do
  response=$(curl "${curl_args[@]}" "${api_url}?per_page=100&page=${page}")
  if ! jq -e 'type == "array" and all(.[]; (.tag_name | type) == "string")' \
    >/dev/null <<< "$response"; then
    echo "GitHub API returned an unexpected response for ${repo}" >&2
    exit 1
  fi

  page_tags=$(jq -r '.[].tag_name' <<< "$response")
  while IFS= read -r tag; do
    [[ -n "$tag" ]] && release_tags+=("$tag")
  done <<< "$page_tags"

  page_count=$(jq 'length' <<< "$response")
  (( page_count < 100 )) && break
  ((page += 1))
done

if (( ${#release_tags[@]} > 0 )); then
  echo "latest tag: ${release_tags[0]}"
else
  echo "latest tag: none"
fi
echo "total releases: ${#release_tags[@]}"
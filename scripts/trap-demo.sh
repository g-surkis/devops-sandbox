#!/usr/bin/env bash
set -euo pipefail

WORKDIR=$(mktemp -d)   # unique temp dir, e.g. /var/folders/.../tmp.XXXX on macOS

cleanup() {
  local exit_code=$?                        # capture the script's exit code before anything else changes it
  rm -rf "$WORKDIR"
  echo "cleanup: removed $WORKDIR (exit code $exit_code)"
}
trap cleanup EXIT   
trap 'exit 130' INT    # Ctrl+C: exit with the conventional code 128+2; the EXIT trap still runs and now sees 130
trap 'exit 143' TERM   # SIGTERM (e.g. pod shutdown in Kubernetes): 128+15                        # run cleanup on ANY exit: success, error via set -e, or Ctrl+C

echo "working in $WORKDIR"
echo "fake dump" > "$WORKDIR/db.sql"

if [[ "${FAIL:-}" == "1" ]]; then           # ${FAIL:-} = empty if unset, so -u doesn't complain
  echo "simulating failure"
  false                                     # 'false' returns 1 -> set -e exits -> trap still runs
fi

if [[ "${SLOW:-}" == "1" ]]; then
  echo "sleeping 30s, press Ctrl+C"
  sleep 30
fi

echo "success"
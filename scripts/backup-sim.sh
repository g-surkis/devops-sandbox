#!/usr/bin/env bash
# Stop on errors, unset variables, and failures inside a pipeline.
set -euo pipefail

# Create a unique temporary directory; use TMPDIR when it is set, otherwise /tmp.
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/backup-sim.XXXXXX")
# Delete the temporary directory on every normal exit, including after an error.
trap 'rm -rf "$tmpdir"' EXIT
# Turn Ctrl+C into a normal exit so the EXIT cleanup trap runs.
trap 'exit 130' INT

# Show where the temporary files are being written.
printf 'Temporary directory: %s\n' "$tmpdir"
# Write a small text file to stand in for a database dump.
printf 'Simulated database dump\n' > "$tmpdir/dump.sql"

# Create a tar archive and pass it to gzip; save the compressed result in the temp directory.
tar -cf - -C "$tmpdir" dump.sql | gzip -c > "$tmpdir/backup.tar.gz"
# Tell the user that the archive step finished.
printf 'Backup archive created.\n'

# Choose an optional demonstration mode from the first command-line argument.
case "${1:-}" in
  "")
    # No extra mode: continue to the success message.
    ;;
  --fail)
    # Deliberately fail to demonstrate that strict mode stops the script.
    printf 'Simulating a backup failure.\n' >&2
    false
    ;;
  --wait)
    # Keep running until Ctrl+C is pressed, so the interrupt trap can be tested.
    printf 'Waiting; press Ctrl+C to stop.\n'
    while :; do sleep 1; done
    ;;
  *)
    # Reject unsupported arguments and show the accepted options.
    printf 'Usage: %s [--fail|--wait]\n' "$0" >&2
    exit 2
    ;;
esac

# This line is reached only if the backup simulation succeeds.
printf 'Backup simulation completed successfully.\n'
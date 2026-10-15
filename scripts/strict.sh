#!/usr/bin/env bash
set -euo pipefail   # -e: exit on error, -u: error on unset vars, pipefail: pipeline fails if any part fails

# echo "step 1: read config"
# cat /nonexistent/config.json

# echo "step 2: build target path"
# TARGET="$BACKUP_DIR/db.sql"
# echo "would write to: '$TARGET'"

echo "step 3: pipeline"
cat /nonexistent/data.txt | wc -l
echo "pipeline exit code: $?"

echo "DONE - reported success" 
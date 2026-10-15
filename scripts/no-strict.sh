#!/usr/bin/env bash
# No strict mode: errors are ignored and the script keeps going

echo "step 1: read config"
cat /nonexistent/config.json          # fails: file does not exist

echo "step 2: build target path"
TARGET="$BACKUP_DIR/db.sql"           # BACKUP_DIR is never set -> silently empty
echo "would write to: '$TARGET'"

echo "step 3: pipeline"
cat /nonexistent/data.txt | wc -l     # cat fails, but wc succeeds -> pipeline 'succeeds'
echo "pipeline exit code: $?"

echo "DONE - reported success"
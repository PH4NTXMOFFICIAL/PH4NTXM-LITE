#!/usr/bin/env bash
set -euo pipefail

RUN_DIR=/run/ph4ntxm
OFFSET_FILE="$RUN_DIR/clock-offset-ms"
LOCK_FILE="$RUN_DIR/clock-fuzz.lock"

mkdir -p "$RUN_DIR"

[ -e "$LOCK_FILE" ] && exit 0
touch "$LOCK_FILE"

MIN=500
MAX=5000

MAG=$(( MIN + RANDOM % (MAX - MIN + 1) ))

if [ $((RANDOM % 2)) -eq 0 ]; then
    OFFSET_MS="$MAG"
else
    OFFSET_MS="-$MAG"
fi

EPOCH=$(date +%s)
NEW_EPOCH=$(awk -v e="$EPOCH" -v o="$OFFSET_MS" 'BEGIN{printf("%.3f", e + o/1000)}')

date -s "@$NEW_EPOCH" >/dev/null 2>&1 || true

printf '%d\n' "$OFFSET_MS" > "$OFFSET_FILE"
chmod 644 "$OFFSET_FILE" || true

exit 0
#!/bin/sh
set -eu

RUN_DIR=/run/ph4ntxm
MODE_FILE="$RUN_DIR/mode"

mkdir -p "$RUN_DIR"

mode=""

for arg in $(cat /proc/cmdline); do
    case "$arg" in
        ph4ntxm.mode=*)
            mode="${arg#ph4ntxm.mode=}"
            ;;
    esac
done

[ -n "$mode" ] || exit 0

case "$mode" in
    windows|linux|android)
        printf '%s\n' "$mode" > "$MODE_FILE"
        ;;
    *)
        exit 0
        ;;
esac

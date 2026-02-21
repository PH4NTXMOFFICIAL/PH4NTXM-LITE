#!/usr/bin/env bash
set -euo pipefail

MODE_FILE=/run/ph4ntxm/mode
SESSION_FILE=/run/ph4ntxm/session_dhcp

mkdir -p /run/ph4ntxm

[[ -r "$MODE_FILE" ]] || exit 0
MODE="$(tr -d '\n' < "$MODE_FILE")"

HOSTNAME="$(cat /etc/hostname 2>/dev/null || echo unknown)"

case "$MODE" in
    linux)
        VENDOR="dhclient"
        TIMEOUT=60
        DUID="ll"
        ;;
    windows)
        VENDOR="MSFT 5.0"
        TIMEOUT=45
        DUID="stable-uuid"
        ;;
    android)
        VENDOR="android-dhcp"
        TIMEOUT=30
        DUID="ll"
        ;;
    *)
        exit 0
        ;;
esac

printf 'MODE=%q\nVENDOR=%q\nHOSTNAME=%q\nTIMEOUT=%q\nDUID=%q\n' \
    "$MODE" "$VENDOR" "$HOSTNAME" "$TIMEOUT" "$DUID" > "$SESSION_FILE"

chmod 600 "$SESSION_FILE"
exit 0
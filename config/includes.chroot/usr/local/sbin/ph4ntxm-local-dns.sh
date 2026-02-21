#!/usr/bin/env bash
set -euo pipefail

if ! systemctl is-active --quiet unbound; then
    exit 0
fi

echo "nameserver 127.0.0.1" > /etc/resolv.conf

exit 0
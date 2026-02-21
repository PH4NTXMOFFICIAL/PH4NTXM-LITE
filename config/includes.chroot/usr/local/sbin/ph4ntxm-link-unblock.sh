#!/bin/bash
set -e

for dev in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    ip link set "$dev" up || true
done
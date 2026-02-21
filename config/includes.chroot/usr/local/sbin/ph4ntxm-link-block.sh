#!/bin/bash
set -e

ip link set lo up

for dev in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    ip link set "$dev" down || true
done
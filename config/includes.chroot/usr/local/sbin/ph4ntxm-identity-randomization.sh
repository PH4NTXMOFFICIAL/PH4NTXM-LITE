#!/usr/bin/env bash
set -euo pipefail
safe() { "$@" >/dev/null 2>&1 || true; }

MODE_FILE="/run/ph4ntxm/mode"
STATE_DIR="/run/ph4ntxm"
BOOT_MAC_FILE="$STATE_DIR/boot_mac"
BOOT_MID_FILE="$STATE_DIR/boot_machine_id"

mkdir -p "$STATE_DIR"

declare -A OUI_POOL=(
  [lenovo]="3c:52:82"
  [dell]="f8:b1:56"
  [hp]="3c:d9:2b"
  [asus]="2c:56:dc"
  [acer]="20:6a:8a"
  [msi]="d8:cb:8a"
  [samsung]="3c:5a:b4"
  [google]="f4:f5:d8"
  [xiaomi]="64:09:80"
  [oneplus]="ac:61:ea"
  [sony]="00:19:c5"
  [motorola]="60:38:e0"
)

generate_hostname() {
  [ -r "$MODE_FILE" ] || return 1
  MODE="$(tr -d '\n' < "$MODE_FILE")"

  rnd() { tr -dc 'a-z0-9' </dev/urandom | head -c4; }

  declare -A hw_families=(
    [lenovo]="thinkpad ideapad thinkcentre"
    [dell]="xps latitude optiplex"
    [hp]="elitebook probook pavilion"
    [asus]="zenbook vivobook"
    [acer]="swift aspire"
    [msi]="prestige stealth"
    [samsung]="galaxybook"
    [google]="pixel"
    [xiaomi]="redmi"
    [oneplus]="oneplus"
    [sony]="xperia"
    [motorola]="moto"
  )

  case "$MODE" in
    linux|windows)
      vendors=(lenovo dell hp asus acer msi samsung)
      ;;
    android)
      vendors=(google xiaomi oneplus sony motorola)
      ;;
    *)
      return 1
      ;;
  esac

  V="${vendors[$((RANDOM % ${#vendors[@]}))]}"
  SELECTED_VENDOR="$V"

  families=(${hw_families[$V]})
  F="${families[$((RANDOM % ${#families[@]}))]}"

  HOST="${F}-$(rnd)"
  HOST="$(printf "%s" "$HOST" | tr '[:upper:]' '[:lower:]')"

  printf '%s' "${HOST:0:32}"
}

generate_mac() {
  vendor="$1"
  OUI="${OUI_POOL[$vendor]}"
  [ -z "$OUI" ] && return 1

  suffix=$(hexdump -n3 -e '/1 ":%02x"' /dev/urandom)
  printf "%s%s\n" "$OUI" "$suffix"
}

if [ ! -f "$BOOT_MAC_FILE" ]; then
  HOST="$(generate_hostname)"
  if [ -n "${SELECTED_VENDOR:-}" ]; then
    generate_mac "$SELECTED_VENDOR" > "$BOOT_MAC_FILE"
  fi
else
  HOST="$(generate_hostname)"
fi

BOOT_MAC="$(cat "$BOOT_MAC_FILE" 2>/dev/null || true)"

if [ -n "$BOOT_MAC" ]; then
  for devpath in /sys/class/net/*; do
    iface=$(basename "$devpath")
    [ "$iface" = "lo" ] && continue
    [ -d "/sys/class/net/$iface/device" ] || continue
    safe ip link set "$iface" down
    safe ip link set "$iface" address "$BOOT_MAC"
    safe ip link set "$iface" up
  done
fi

if [ ! -f "$BOOT_MID_FILE" ]; then
  head -c16 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$BOOT_MID_FILE"
fi

BOOT_MID="$(cat "$BOOT_MID_FILE")"
printf '%s\n' "$BOOT_MID" > /etc/machine-id
safe chmod 0644 /etc/machine-id

printf '%s\n' "$HOST" > /etc/hostname.tmp
safe mv /etc/hostname.tmp /etc/hostname

if grep -q '^127\.0\.1\.1' /etc/hosts 2>/dev/null; then
  safe sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$HOST/" /etc/hosts
else
  printf '\n127.0.1.1\t%s\n' "$HOST" >> /etc/hosts
fi

safe hostname "$HOST"
safe chmod 0644 /etc/hostname /etc/hosts

exit 0
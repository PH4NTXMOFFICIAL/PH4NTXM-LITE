#!/usr/bin/env bash
set -euo pipefail

MODE_FILE=/run/ph4ntxm/mode
SYSCTL=$(command -v sysctl || true)

[ -r "$MODE_FILE" ] || exit 0
MODE="$(tr -d '\n' < "$MODE_FILE")"

[ -n "$SYSCTL" ] || exit 0

case "$MODE" in
  windows)
    TTL=128
    PORT_LOW=49152
    PORT_HIGH=65535
    SYN_RETRIES=3
    SYNACK_RETRIES=3
    FIN_TIMEOUT=45
    KEEP_TIME=7200
    KEEP_INTVL=1
    KEEP_PROBES=10
    MTU_PROBING=0
    FASTOPEN=0
    ECN=0
    CC="cubic"
    ICMP_RATE=1000
    ;;
  android)
    TTL=64
    PORT_LOW=32768
    PORT_HIGH=61000
    SYN_RETRIES=6
    SYNACK_RETRIES=6
    FIN_TIMEOUT=30
    KEEP_TIME=2400
    KEEP_INTVL=10
    KEEP_PROBES=5
    MTU_PROBING=1
    FASTOPEN=1
    ECN=1
    CC="bbr"
    ICMP_RATE=500
    ;;
  linux|*)
    TTL=64
    PORT_LOW=32768
    PORT_HIGH=60999
    SYN_RETRIES=6
    SYNACK_RETRIES=6
    FIN_TIMEOUT=40
    KEEP_TIME=5400
    KEEP_INTVL=15
    KEEP_PROBES=5
    MTU_PROBING=1
    FASTOPEN=1
    ECN=1
    CC="cubic"
    ICMP_RATE=1000
    ;;
esac

if [[ -n "$SYSCTL" ]]; then
$SYSCTL -w net.ipv4.ip_default_ttl="$TTL" >/dev/null
$SYSCTL -w net.ipv4.ip_local_port_range="$PORT_LOW $PORT_HIGH" >/dev/null
$SYSCTL -w net.ipv4.tcp_syn_retries="$SYN_RETRIES" >/dev/null
$SYSCTL -w net.ipv4.tcp_synack_retries="$SYNACK_RETRIES" >/dev/null
$SYSCTL -w net.ipv4.tcp_fin_timeout="$FIN_TIMEOUT" >/dev/null
$SYSCTL -w net.ipv4.tcp_keepalive_time="$KEEP_TIME" >/dev/null
$SYSCTL -w net.ipv4.tcp_keepalive_intvl="$KEEP_INTVL" >/dev/null
$SYSCTL -w net.ipv4.tcp_keepalive_probes="$KEEP_PROBES" >/dev/null
$SYSCTL -w net.ipv4.tcp_mtu_probing="$MTU_PROBING" >/dev/null
$SYSCTL -w net.ipv4.tcp_fastopen="$FASTOPEN" >/dev/null
$SYSCTL -w net.ipv4.tcp_ecn="$ECN" >/dev/null
$SYSCTL -w net.ipv4.icmp_ratelimit="$ICMP_RATE" >/dev/null

if $SYSCTL net.ipv4.tcp_available_congestion_control 2>/dev/null | grep -q "$CC"; then
  $SYSCTL -w net.ipv4.tcp_congestion_control="$CC" >/dev/null
fi

$SYSCTL -w net.ipv6.conf.all.use_tempaddr=2 >/dev/null 2>&1 || true
$SYSCTL -w net.ipv6.conf.default.use_tempaddr=2 >/dev/null 2>&1 || true
fi

exit 0
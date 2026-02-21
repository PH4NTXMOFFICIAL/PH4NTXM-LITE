#!/bin/bash
set -euo pipefail

UNBOUND_CONF="/etc/unbound/unbound.conf.d/ph4ntxm.conf"

providers=("cloudflare" "google" "quad9" "cleanbrowsing" "controld")

cloudflare_v4=("1.1.1.1")
cloudflare_v6=("2606:4700:4700::1111")
cloudflare_host="cloudflare-dns.com"

google_v4=("8.8.8.8")
google_v6=("2001:4860:4860::8888")
google_host="dns.google"

quad9_v4=("9.9.9.9")
quad9_v6=("2620:fe::fe")
quad9_host="dns.quad9.net"

cleanbrowsing_v4=("185.228.168.9")
cleanbrowsing_v6=("2a0d:2a00:1::2")
cleanbrowsing_host="security-filter-dns.cleanbrowsing.org"

controld_v4=("76.76.2.0")
controld_v6=("2602:fddd:2::2")
controld_host="dns.controld.com"

PROVIDER="$(shuf -e "${providers[@]}" -n 1)"

v4_var="${PROVIDER}_v4[@]"
v6_var="${PROVIDER}_v6[@]"
host_var="${PROVIDER}_host"

v4_list=("${!v4_var}")
v6_list=("${!v6_var}")
TLS_HOST="${!host_var}"

RANDOM_V4="$(shuf -e "${v4_list[@]}" -n 1)"
RANDOM_V6="$(shuf -e "${v6_list[@]}" -n 1)"

mkdir -p /etc/unbound/unbound.conf.d

cat > "$UNBOUND_CONF" <<EOF
server:
    interface: 127.0.0.1
    access-control: 127.0.0.0/8 allow
    cache-min-ttl: 300
    cache-max-ttl: 14400
    hide-identity: yes
    hide-version: yes
    qname-minimisation: yes
    harden-dnssec-stripped: yes
    harden-glue: yes
    use-caps-for-id: yes
    prefetch: yes
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt

forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: ${RANDOM_V4}@853#${TLS_HOST}
    forward-addr: ${RANDOM_V6}@853#${TLS_HOST}
EOF

exit 0
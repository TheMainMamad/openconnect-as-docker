#!/bin/bash
set -euo pipefail

error() {
  echo "❌ ERROR: $1" >&2
  exit 1
}

log() {
  echo "▶ $1"
}

[ -z "${PASSWORD:-}" ] && error "\$PASSWORD is not set"
[ -z "${HOST:-}" ] && error "\$HOST is not set"
[ -z "${USERNAME:-}" ] && error "\$USERNAME is not set"
[ -z "${GROUP:-}" ] && error "\$GROUP is not set"
[ -z "${SERVER_PIN_CERT:-}" ] && error "\$SERVER_PIN_CERT is not set"
[ -z "${PROTOCOL:-}" ] && error "\$PROTOCOL is not set"
[ -z "${SPLIT_ROUTES:-}" ] && error "\$SPLIT_ROUTES is not set"

#
VPN_IFACE="${VPN_IFACE:-tun0}"
SPLIT_ROUTES="${SPLIT_ROUTES:-}"
NO_DTLS="${NO_DTLS:-true}"

NO_DTLS_FLAG=""
[ "$NO_DTLS" = "true" ] && NO_DTLS_FLAG="--no-dtls"

log "Starting OpenConnect VPN..."

printf '%s\n' "$PASSWORD" | openconnect \
  --non-inter \
  --protocol="$PROTOCOL" \
  "$HOST" \
  -u "$USERNAME" \
  --authgroup="$GROUP" \
  --servercert "$SERVER_PIN_CERT" \
  --passwd-on-stdin \
  $NO_DTLS_FLAG \
  --background

log "Waiting for VPN interface ($VPN_IFACE)..."

for i in {1..15}; do
  if ip link show "$VPN_IFACE" >/dev/null 2>&1; then
    log "VPN interface is up"
    break
  fi
  sleep 1
done

ip link show "$VPN_IFACE" >/dev/null 2>&1 || error "VPN interface not found"

if ip route | grep -q "^default.*$VPN_IFACE"; then
  log "Default route was set to VPN, fixing it"
  ip route del default dev "$VPN_IFACE" || true
fi

if [ -n "$SPLIT_ROUTES" ]; then
  log "Applying split tunnel routes"
  for route in $SPLIT_ROUTES; do
    log "  routing $route via $VPN_IFACE"
    ip route add "$route" dev "$VPN_IFACE" || true
  done
else
  log "No split routes defined (full access via default route)"
fi

if [ -n "$DNS" ]; then
  echo "" > /etc/resolv.conf
  log "Configuring DNS"
  for dns_addr in $DNS; do
    echo -e "nameserver $dns_addr" >> /etc/resolv.conf
  done
  else
    log "No dns found. skipping"
fi

log "IP addresses:"
ip a

log "Routing table:"
ip route

log "VPN is up and running"
tail -f /dev/null

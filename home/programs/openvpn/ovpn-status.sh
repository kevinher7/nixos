# shellcheck shell=bash

OVPN_RUNDIR="$HOME/.cache/ovpn"
OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"
OVPN_PIN_BEGIN="# BEGIN ovpn split-tunnel pins"
OVPN_PIN_END="# END ovpn split-tunnel pins"

pid="$(cat "$OVPN_PIDFILE" 2>/dev/null || true)"
if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
  echo "🟢 OpenVPN running (pid $pid)." >&2
else
  echo "⚪ OpenVPN not running." >&2
fi

# Probe each pinned IP: 000 means the origin moved, 403 means we aren't
# egressing through the VPN. DNS drift itself is expected and harmless.
pins="$(sed -n "\%$OVPN_PIN_BEGIN%,\%$OVPN_PIN_END%p" /etc/hosts 2>/dev/null | grep -E '^[0-9]' || true)"
if [ -z "$pins" ]; then
  echo "   No pinned hosts." >&2
else
  while read -r ip host; do
    code="$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 --max-time 8 \
      --resolve "$host:443:$ip" "https://$host/" 2>/dev/null || true)"
    case "$code" in
      000 | "") echo "   ⚠️  $host → $ip unreachable (stale pin: ovpn-down && ovpn)" >&2 ;;
      403) echo "   ⚠️  $host → $ip rejected (not egressing via VPN)" >&2 ;;
      *) echo "   ✅ $host → $ip ($code)" >&2 ;;
    esac
  done <<<"$pins"
fi

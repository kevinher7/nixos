# shellcheck shell=bash

OVPN_RUNDIR="$HOME/.cache/ovpn"
OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"
OVPN_PIN_BEGIN="# BEGIN ovpn split-tunnel pins"
OVPN_PIN_END="# END ovpn split-tunnel pins"

pid="$(sudo cat "$OVPN_PIDFILE" 2>/dev/null || true)"
if [ -n "$pid" ] && sudo kill "$pid" 2>/dev/null; then
  echo "🔌 OpenVPN disconnected (pid $pid)." >&2
elif sudo pkill -x openvpn 2>/dev/null; then
  echo "🔌 OpenVPN disconnected." >&2
else
  echo "ovpn-down: no running OpenVPN found." >&2
fi
sudo rm -f "$OVPN_PIDFILE"

if grep -q "$OVPN_PIN_BEGIN" /etc/hosts 2>/dev/null; then
  sudo sed -i '' "\%$OVPN_PIN_BEGIN%,\%$OVPN_PIN_END%d" /etc/hosts
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder 2>/dev/null || true
  echo "🧹 Removed /etc/hosts pins." >&2
fi

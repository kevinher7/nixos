# shellcheck shell=bash

OVPN_RUNDIR="$HOME/.cache/ovpn"
OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"

pid="$(sudo cat "$OVPN_PIDFILE" 2>/dev/null || true)"
if [ -n "$pid" ] && sudo kill "$pid" 2>/dev/null; then
  echo "🔌 OpenVPN disconnected (pid $pid)." >&2
elif sudo pkill -x openvpn 2>/dev/null; then
  echo "🔌 OpenVPN disconnected." >&2
else
  echo "ovpn-down: no running OpenVPN found." >&2
fi
sudo rm -f "$OVPN_PIDFILE"

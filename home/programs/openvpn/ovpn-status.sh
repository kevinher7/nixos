# shellcheck shell=bash

OVPN_RUNDIR="$HOME/.cache/ovpn"
OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"

pid="$(cat "$OVPN_PIDFILE" 2>/dev/null || true)"
if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
  echo "🟢 OpenVPN running (pid $pid)." >&2
else
  echo "⚪ OpenVPN not running." >&2
fi

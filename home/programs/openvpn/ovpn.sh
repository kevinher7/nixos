# shellcheck shell=bash

OVPN_RUNDIR="$HOME/.cache/ovpn"
OVPN_PIDFILE="$OVPN_RUNDIR/openvpn.pid"
OVPN_LOGFILE="$OVPN_RUNDIR/openvpn.log"

# Site-specific values are kept out of this (public) repo. Override them
# in ~/.config/ovpn/env, e.g.:  OVPN_VAULT="My Vault"
# shellcheck source=/dev/null
[ -f "$HOME/.config/ovpn/env" ] && source "$HOME/.config/ovpn/env"
OVPN_VAULT="${OVPN_VAULT:-Local Development}"   # 1Password vault
OVPN_ITEM="${OVPN_ITEM:-VPN}"                   # Login item: user/pass + .ovpn attachment
OVPN_FILE="${OVPN_FILE:-client-config.ovpn}"    # .ovpn attachment name

# Refuse to stack a second tunnel on top of a running one.
if [ -f "$OVPN_PIDFILE" ] && ps -p "$(cat "$OVPN_PIDFILE" 2>/dev/null)" >/dev/null 2>&1; then
  echo "ovpn: already connected (pid $(cat "$OVPN_PIDFILE")). Run ovpn-down first." >&2
  exit 1
fi

user="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/username")" \
  || { echo "ovpn: couldn't read username from 1Password" >&2; exit 1; }

pass="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/password")" \
  || { echo "ovpn: couldn't read password from 1Password" >&2; exit 1; }

if [ -n "${1:-}" ]; then
  config="$(cat "$1")" \
    || { echo "ovpn: couldn't read profile $1" >&2; exit 1; }
else
  config="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/$OVPN_FILE")" \
    || { echo "ovpn: couldn't read profile from 1Password" >&2; exit 1; }
fi

# Hosts to route through the VPN: read from the 1Password item's optional
# "split_hosts" field (space/newline-separated). This is the only source.
OVPN_SPLIT_HOSTS="$(op read "op://$OVPN_VAULT/$OVPN_ITEM/split_hosts" 2>/dev/null || true)"

echo "🔐 Connecting OpenVPN as $user..." >&2
mkdir -p "$OVPN_RUNDIR"

# Resolve the split-tunnel hosts to IPs and build --route flags.
route_opts=()
# Word-splitting on whitespace/newlines is intentional here.
# shellcheck disable=SC2086
for host in $OVPN_SPLIT_HOSTS; do
  # shellcheck disable=SC2046
  for ip in $(dig +short "$host" | grep -E '^[0-9.]+$' || true); do
    route_opts+=(--route "$ip" 255.255.255.255)
  done
done

if [ -n "$OVPN_SPLIT_HOSTS" ] && [ ${#route_opts[@]} -eq 0 ]; then
  echo "ovpn: warning — couldn't resolve split hosts ($OVPN_SPLIT_HOSTS); they may be unreachable" >&2
fi

# sudo closes inherited fds (closefrom), so /dev/fd process substitution
# can't reach the root openvpn process. Pass the profile + credentials
# through FIFOs instead: real paths root can open, backed only by kernel
# buffers, so no secret is ever written to a regular file.
dir="$(mktemp -d)" || exit 1
cfg="$dir/config.ovpn"
auth="$dir/auth"
mkfifo -m 600 "$cfg" "$auth"

printf '%s\n' "$config" > "$cfg" &
cfg_pid=$!
printf '%s\n%s\n' "$user" "$pass" > "$auth" &
auth_pid=$!

# Ignore the pushed full-tunnel redirect + DNS so we coexist with other VPNs.
rc=0
sudo openvpn --config "$cfg" --auth-user-pass "$auth" \
  --pull-filter ignore "redirect-gateway" \
  --pull-filter ignore "dhcp-option DNS" \
  --pull-filter ignore "dhcp-option DOMAIN-ROUTE" \
  "${route_opts[@]}" \
  --daemon ovpn --writepid "$OVPN_PIDFILE" --log "$OVPN_LOGFILE" --verb 3 \
  || rc=$?

# Reap the FIFO writers once openvpn has read them (no huponexit, so this
# backgrounded subshell outlives us).
( sleep 10; kill "$cfg_pid" "$auth_pid" 2>/dev/null || true; rm -rf "$dir" ) &

if [ "$rc" -eq 0 ]; then
  echo "✅ OpenVPN started in background. Disconnect with: ovpn-down" >&2
  echo "   Status: ovpn-status   Logs: sudo tail -f $OVPN_LOGFILE" >&2
else
  kill "$cfg_pid" "$auth_pid" 2>/dev/null || true
  rm -rf "$dir"
  echo "ovpn: failed to start (rc=$rc); see $OVPN_LOGFILE" >&2
fi
exit "$rc"

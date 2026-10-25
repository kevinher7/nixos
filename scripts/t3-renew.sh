#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <uribo-btw|kebean|beans-btw>\n' "$0"
}

if [[ $# -eq 1 && "$1" == --help ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

declare -A service_users=(
  [uribo-btw]=agent
  [kebean]=agent
  [beans-btw]=kevin
)

declare -A login_users=(
  [uribo-btw]=uribo
  [kebean]=kevin
  [beans-btw]=kevin
)

if [[ -z "${service_users[$1]:-}" ]]; then
  printf 'Unknown T3 Code host: %s\n' "$1" >&2
  usage >&2
  exit 1
fi

service_user="${service_users[$1]}"
login_user="${login_users[$1]}"

run_as=""
if [[ "$service_user" != "$login_user" ]]; then
  run_as="sudo -H -u ${service_user} "
fi

printf 'Generating a pairing link for %s on its tailnet address.\n' "$1"
printf 'Desktop app: Settings > Connections > Add environment, paste the printed link.\n'
printf 'Mobile app: Settings > Environments, scan the QR code or paste the printed link.\n'
printf 'The link expires after five minutes. Your new session lasts 30 days.\n\n'

output=$(ssh -t -o ConnectTimeout=10 -- "${login_user}@$1" \
  "${run_as}/etc/profiles/per-user/${service_user}/bin/t3 auth pairing create --base-dir /var/lib/t3code --label $1 --base-url http://\$(tailscale ip -4):3773" |
  tee /dev/tty | tr -d '\r')

pairing_url=$(grep -oE 'https?://[^[:space:]]+/pair#token=[^[:space:]]+' <<<"$output" | head -n 1 || true)

if [[ -z "$pairing_url" ]]; then
  printf '\nNo pairing link found in the output above.\n' >&2
  exit 1
fi

printf '\n'
nix run nixpkgs#qrencode -- -t ansiutf8 -m 2 "$pairing_url"

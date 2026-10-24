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
  [kebean]=kevin
  [beans-btw]=kevin
)

if [[ -z "${service_users[$1]:-}" ]]; then
  printf 'Unknown T3 Code host: %s\n' "$1" >&2
  usage >&2
  exit 1
fi

service_user="${service_users[$1]}"

printf 'Generating a pairing link for %s at http://%s:3773.\n' "$1" "$1"
printf 'Desktop app: Settings > Connections > Add environment, paste the printed link.\n'
printf 'Mobile app: Settings > Environments, paste the printed link.\n'
printf 'The link expires after five minutes. Your new session lasts 30 days.\n\n'

exec ssh -o ConnectTimeout=10 -- "${service_user}@$1" \
  "/etc/profiles/per-user/${service_user}/bin/t3 pair --base-dir /var/lib/t3code --label $1"

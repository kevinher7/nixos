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

case "$1" in
  uribo-btw)
    service_user=uribo
    pairing_command='auth pairing create --base-url https://t3code.beanhaven.net'
    ;;
  kebean | beans-btw)
    service_user=kevin
    pairing_command='pair --tailscale'
    ;;
  *)
    printf 'Unknown T3 Code host: %s\n' "$1" >&2
    usage >&2
    exit 1
    ;;
esac

printf 'Generating a pairing link on %s.\n' "$1"
if [[ "$1" == uribo-btw ]]; then
  printf 'Open the full printed link to sign in to t3code.beanhaven.net.\n'
else
  printf 'In t3code.beanhaven.net, open Settings > Connections > Add environment.\n'
  printf 'Paste the full printed link there. This token will not work at t3code.beanhaven.net/pair.\n'
  printf 'If that site needs a token, first run: %s uribo-btw\n' "$0"
fi
printf 'The link expires after five minutes. Your new session lasts 30 days.\n\n'

exec ssh -o ConnectTimeout=10 -- "${service_user}@$1" \
  "/etc/profiles/per-user/${service_user}/bin/t3 ${pairing_command} --base-dir /var/lib/t3code --label $1"

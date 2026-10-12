#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
config_path="$repo_root/home/desktops/sway/quickshell"
service=quickshell.service
environment=$(systemctl --user show "$service" --property=Environment --value)
config_file="$config_path/shell.qml"

if quickshell list --all 2>/dev/null | grep -Fq "Config path: $config_file"; then
  replace_running_instance=true
else
  replace_running_instance=false
fi

env -S "$environment" quickshell --path "$config_path" --daemonize
systemctl --user stop "$service"

if [[ $replace_running_instance == true ]]; then
  quickshell kill --path "$config_path"
fi

device_name="${1:?Usage: toggle-bluetooth DEVICE_NAME}"
devices="$(bluetoothctl devices)"
device=

while read -r _ address name; do
  if [[ "$name" == "$device_name" ]]; then
    device="$address"
    break
  fi
done <<< "$devices"

if [[ -z "$device" ]]; then
  notify-send --urgency=critical "$device_name" "Bluetooth device not found"
  exit 1
fi

if ! device_info="$(bluetoothctl info "$device" 2>&1)"; then
  notify-send --urgency=critical "$device_name" "Could not check connection: $device_info"
  exit 1
fi

action=connect
if [[ "$device_info" == *"Connected: yes"* ]]; then
  action=disconnect
fi

if ! result="$(bluetoothctl --timeout 20 "$action" "$device" 2>&1)"; then
  notify-send --urgency=critical "$device_name" "Could not $action: $result"
  exit 1
fi

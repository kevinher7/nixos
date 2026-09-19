# @vicinae.schemaVersion 1
# @vicinae.title Toggle Bluetooth
# @vicinae.mode fullOutput

export LC_ALL=C
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/vicinae"
devices_file="$state_dir/bluetooth-devices"

if ! controller=$(timeout 2s bluetoothctl show 2>&1); then
  printf 'Cannot read Bluetooth adapter: %s\n' "$controller"
  exit 1
fi

if [[ $controller =~ Powered:[[:space:]]+yes ]]; then
  power=off
  expected=no
  if ! devices=$(timeout 2s bluetoothctl devices Connected 2>&1); then
    printf 'Cannot remember connected devices: %s\n' "$devices"
    exit 1
  fi
  if [[ -n $devices ]]; then
    mkdir -p "$state_dir"
    printf '%s\n' "$devices" > "$devices_file"
  fi
elif [[ $controller =~ Powered:[[:space:]]+no ]]; then
  power=on
  expected=yes
else
  echo "No Bluetooth adapter available"
  exit 1
fi

if ! result=$(timeout 4s bluetoothctl power "$power" 2>&1); then
  printf 'Cannot turn Bluetooth %s: %s\n' "$power" "$result"
  exit 1
fi

if ! controller=$(timeout 2s bluetoothctl show 2>&1) ||
   [[ ! $controller =~ Powered:[[:space:]]+$expected ]]; then
  printf 'Bluetooth did not turn %s: %s\n' "$power" "$result"
  exit 1
fi
printf 'Bluetooth turned %s\n' "$power"
[[ $power == on ]] || exit 0

if [[ -s $devices_file ]]; then
  devices=$(cat "$devices_file")
else
  if ! devices=$(timeout 2s bluetoothctl devices Paired 2>&1); then
    printf 'Cannot list paired devices: %s\n' "$devices"
    exit 1
  fi
  # Without saved history, only choose a device if there is no ambiguity.
  if [[ -z $devices || $devices == *$'\n'* ]]; then
    echo "No previous connection saved. Connect a device once before toggling off."
    exit 0
  fi
fi

failed=0
while read -r prefix address name; do
  if [[ $prefix != Device || ! $address =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
    echo "Invalid saved Bluetooth device"
    failed=1
    continue
  fi

  printf 'Connecting to %s...\n' "$name"
  if ! result=$(timeout 15s bluetoothctl connect "$address" 2>&1); then
    printf 'Bluetooth is on, but could not connect to %s: %s\n' "$name" "$result"
    failed=1
    continue
  fi
  if ! device=$(timeout 2s bluetoothctl info "$address" 2>&1) ||
     [[ ! $device =~ Connected:[[:space:]]+yes ]]; then
    printf 'Bluetooth is on, but %s did not connect.\n' "$name"
    failed=1
    continue
  fi
  printf 'Connected to %s\n' "$name"
done <<< "$devices"
exit "$failed"

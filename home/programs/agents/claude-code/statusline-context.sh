#!/bin/bash
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
REMAINING=$((100 - USED))
FILLED=$((USED / 10))
EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v F "%${FILLED}s" && BAR="${F// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v E "%${EMPTY}s" && BAR="${BAR}${E// /░}"
COST=$(echo "$input" | jq -r '.session.cost_usd // 0 | . * 100 | round | . / 100')
echo "[$MODEL] Context: $BAR ${USED}% used · ${REMAINING}% left · \$${COST}"

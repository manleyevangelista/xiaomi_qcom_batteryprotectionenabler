#!/system/bin/sh
# Path to Xiaomi's 'night_charging' control node.
NIGHT_CHARGING="/sys/class/qcom-battery/night_charging"
# Battery status node (works across all power sources).
BAT_STATUS="/sys/class/power_supply/battery/status"
# Battery capacity node (used to check current charge %).
BAT_CAPACITY="/sys/class/power_supply/battery/capacity"

# Wait until the "night_charging" node exists.
until [ -f "$NIGHT_CHARGING" ]; do
    sleep 5
done

# Exit if not found (device not compatible).
[ ! -f "$NIGHT_CHARGING" ] && exit 1

PREV_STATUS=""

while true; do
    STATUS=$(cat "$BAT_STATUS" 2>/dev/null)
    CAPACITY=$(cat "$BAT_CAPACITY" 2>/dev/null)

    # React instantly to plug/unplug.
    if [ "$STATUS" != "$PREV_STATUS" ]; then
        if [ "$STATUS" = "Charging" ]; then
            echo "NIGHT_CHARGING: NOT ACTIVATED YET - Plugged in; waiting for 80%."
        else
            echo 0 > "$NIGHT_CHARGING"
            echo "NIGHT_CHARGING: DEACTIVATED - Unplugged or not charging."
        fi
    fi

    # Enable night charging only once the battery hits 80% while charging.
    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -ge 80 ]; then
        echo 1 > "$NIGHT_CHARGING"
        echo "NIGHT_CHARGING: ACTIVATED - Battery is 80% or greater."
    else
        echo 0 > "$NIGHT_CHARGING"
    fi

    PREV_STATUS="$STATUS"
    sleep 5
done &

#!/system/bin/sh
# Combined script: Keeps "night_charging" active only when plugged in and >=80%.

NIGHT_CHARGING="/sys/class/qcom-battery/night_charging"
BAT_STATUS="/sys/class/power_supply/battery/status"
BAT_CAPACITY="/sys/class/power_supply/battery/capacity"

# Wait until the "night_charging" node exists.
until [ -f "$NIGHT_CHARGING" ]; do
    sleep 5
done
sleep 10

# Continuous monitoring loop
while true; do
    STATUS=$(cat "$BAT_STATUS" 2>/dev/null)
    CAPACITY=$(cat "$BAT_CAPACITY" 2>/dev/null)

    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -ge 80 ]; then
        echo 1 > "$NIGHT_CHARGING"
    else
        echo 0 > "$NIGHT_CHARGING"
    fi

    sleep 60  # check every minute
done &
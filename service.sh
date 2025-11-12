#!/system/bin/sh
# Version: Instantly toggles 1→0, then waits 60 seconds before next cycle.
# Activates only when charging and >=80%.

NIGHT_CHARGING="/sys/class/qcom-battery/night_charging"
BAT_STATUS="/sys/class/power_supply/battery/status"
BAT_CAPACITY="/sys/class/power_supply/battery/capacity"

# Wait until node exists
until [ -f "$NIGHT_CHARGING" ]; do
    sleep 5
done
sleep 10

while true; do
    STATUS=$(cat "$BAT_STATUS" 2>/dev/null)
    CAPACITY=$(cat "$BAT_CAPACITY" 2>/dev/null)

    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -ge 80 ]; then
        echo 0 > "$NIGHT_CHARGING"
        echo 1 > "$NIGHT_CHARGING"
    else
        echo 0 > "$NIGHT_CHARGING"
    fi

    sleep 60  # wait 60 seconds before next check
done &
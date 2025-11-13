#!/system/bin/sh

# Xiaomi Battery Protection Pseudo-Backport

# Defines system nodes for easy reference.
NIGHT_CHARGING="/sys/class/qcom-battery/night_charging"
BAT_STATUS="/sys/class/power_supply/battery/status"

# Looks for the "night_charging" ($NIGHT_CHARGING) file. The script runs continuously until the file is found.  
# If the file ($NIGHT_CHARGING) is not found, the script pauses for 5 seconds before searching again.  
# After it is found ($NIGHT_CHARGING), the script pauses for 10 seconds before continuing to the next step.  
until [ -f "$NIGHT_CHARGING" ]; do
    sleep 5
done
sleep 10

# Flags. Basically like a seal. Later in the script, this will be triggered.

LAST_STATUS="" # remembers the last known battery state (Charging or Discharging)
HAS_CHARGED=0 # stays 0 until the phone is plugged in at least once
TOGGLE_TIMER=0 # counts seconds to know when to re-toggle every 60s

# If ($STATUS or $BAT_STAUTUS) is "Charging" (for example if device is plugged in), it toggles (0) off and (1) on) every 60 seconds. Otherwise (let's say if device is unplugged), (0) off is written once, and done.
# The reason it toggles between (0) off and (1) on, is to keep the PMIC in check, to keep "night_charging" active, which limits battery to 80%.

while true; do
    STATUS=$(cat "$BAT_STATUS" 2>/dev/null)

    # Detect first plug-in since boot
    if [ "$STATUS" = "Charging" ]; then
        HAS_CHARGED=1
    fi

    # Only react once the phone has been plugged in at least once
    if [ "$HAS_CHARGED" -eq 1 ]; then
        # Detect state changes
        if [ "$STATUS" != "$LAST_STATUS" ]; then
            if [ "$STATUS" = "Charging" ]; then
                echo 0 > "$NIGHT_CHARGING"
                sleep 1
                echo 1 > "$NIGHT_CHARGING"
                TOGGLE_TIMER=0
            else
                echo 0 > "$NIGHT_CHARGING"
            fi
            LAST_STATUS="$STATUS"
        fi

        # While still charging, toggle between 0 (off) and 1 (on), every 60 seconds
        if [ "$STATUS" = "Charging" ]; then
            TOGGLE_TIMER=$((TOGGLE_TIMER + 1))
            if [ "$TOGGLE_TIMER" -ge 60 ]; then
                echo 0 > "$NIGHT_CHARGING"
                sleep 1
                echo 1 > "$NIGHT_CHARGING"
                TOGGLE_TIMER=0
            fi
        else
            TOGGLE_TIMER=0
        fi
    fi

    sleep 1
done &
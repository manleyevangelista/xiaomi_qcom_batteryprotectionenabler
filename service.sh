#!/system/bin/sh

# Defines system nodes for easy reference.
NIGHT_CHARGING="/sys/class/qcom-battery/night_charging"
BAT_STATUS="/sys/class/power_supply/battery/status"
BAT_CAPACITY="/sys/class/power_supply/battery/capacity"

# Looks for the "night_charging" ($NIGHT_CHARGING) file. The script runs continuously until the file is found.  
# If the file ($NIGHT_CHARGING) is not found, the script pauses for 5 seconds before searching again.  
# After it is found ($NIGHT_CHARGING), the script pauses for 10 seconds before continuing to the next step.  

until [ -f "$NIGHT_CHARGING" ]; do
    sleep 5
done
sleep 10

# Flag to track first plug-in below 80%.
# This acts like a seal that only "breaks" once you pass 80% while charging.

FIRSTPLUG_FLAG=1

# Starts the main loop, and reads battery info.
# In case the nodes disappear, errors will be suppressed.

while true; do
    STATUS=$(cat "$BAT_STATUS" 2>/dev/null)
    CAPACITY=$(cat "$BAT_CAPACITY" 2>/dev/null)

    # If Battery Status is CHARGING and EQUAL OR ABOVE 80%, then flip ($NIGHT_CHARGING) between 0 (off) and 1 (on).
    # Otherwise (on unplug/discharge BELOW 80%), the value reverts/stays at 0 (off).  
    # At first plug, if the battery is CHARGING AND BELOW 80%, nothing happens.
    # At 80%, action starts as soon as FIRSTPLUG_FLAG is changed from 1 to 0.

    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -ge 80 ]; then
        echo 0 > "$NIGHT_CHARGING"
        echo 1 > "$NIGHT_CHARGING"
        FIRSTPLUG_FLAG=0  # Break the seal once charging is EQUAL OR ABOVE 80%.
    elif [ "$STATUS" != "Charging" ] || [ "$CAPACITY" -lt 80 ]; then
        if [ "$FIRSTPLUG_FLAG" -eq 1 ]; then
            # First plug-in BELOW 80%, do nothing
            :
        else
            # Unplugged or below 80% after first plug-in, set 0
            echo 0 > "$NIGHT_CHARGING"
        fi
    fi

    sleep 60 
done &
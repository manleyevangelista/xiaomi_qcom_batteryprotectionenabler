#!/system/bin/sh
# Looks for the "night_charging" ($TARGET) file. The script runs continuously until the file is found.
# If the file ($TARGET) is not found, the script pauses for 5 seconds before searching again.
# After it is found ($TARGET), the script pauses for 10 seconds before continuing to the next step.
until [ -f /sys/class/qcom-battery/night_charging ]; do
    sleep 5
done
sleep 10

TARGET="/sys/class/qcom-battery/night_charging"

# Writes "1" to the $TARGET every minute to keep "night_charging" active.
while true; do
    if [ -f "$TARGET" ]; then
        echo 1 > "$TARGET"
    fi
    sleep 60    # refresh every 1 minute (60 seconds)
done &
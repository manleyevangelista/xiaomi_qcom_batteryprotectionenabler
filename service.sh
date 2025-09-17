#!/system/bin/sh

# This script is delayed by 30 seconds. Without this, permission changes won’t persist.
sleep 30

# Sysfs node that enables 'battery charge limit'.
TARGET="/sys/class/qcom-battery/night_charging"

# Enables 'night_charging', which limits battery to 80%.
echo "1" > $TARGET

# Sets permission to read-only for all users and groups, this prevents the system from changing the value. Which will disable 'night_charging'.
chmod 444 $TARGET
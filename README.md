# Battery Protection Enabler for Older Qualcomm-based Xiaomi Devices

**WARNING**: While this mod shoudn't harm your device, I am still not responsible if anything happens to it while using this module. **USE AT YOUR OWN RISK**.

<img src="https://github.com/manleyevangelista/xiaomi_qcom_batteryprotectionenabler/blob/main/images/BatteryProtectionSettings.jpg" style="width:400px;">

A Magisk module that brings "Battery Protection" on older Xiaomi/Redmi/POCO devices, that do not already have the option in the Settings app. This limits battery charging to 80%. Everything required to turn this on is already available under the hood—it’s just that for some reason, Xiaomi/Redmi/POCO didn’t make it available in the Settings app (on Poco F5 and older). This mod aims to fix that.

This should work on devices with Snapdragon 865 and newer.

## Installation
Simply download the .zip file under the `Releases` section and flash it using Magisk. **DO NOT FLASH THIS IN CUSTOM RECOVERY.**

## How to toggle this on/off?
To turn this off, go to `Modules` section in **Magisk** and turn it off. Same thing in reverse to turn it on.

## Why do I need this? Many custom ROMs already have this feature.
Some may want this under MIUI or HyperOS-based ROMs (includes both stock and xiaomi.eu builds).

Also, on AOSP-based custom ROMs, they use the `input_select` node to limit charging. It does work, but it comes with a caveat: once the specified limit is reached, it produces wakelocks, which drain the battery while the charger is still connected.  Meanwhile, this module uses the `night_charging` node, which works differently. When it hits 80%, instead of letting the battery drain or charge, it draws power directly from the charger—keeping the battery topped at 80%. 

## Troubleshooting
**Problem**:  
My battery still charges past 80%.

**Troubleshooting steps**:

Check if `/sys/class/qcom-battery/night_charging` file exists. If your device does not have it, then this won't work as this module depends on that file. 

To check, type this command using a Terminal app (on your device) or through adb shell (on your computer), and look for `night_charging` file.

```
ls /sys/class/qcom-battery/
```

If the file exists, continue typing these commands below:

```
su
cat -l /sys/class/qcom-battery/night_charging && ls -l /sys/class/qcom-battery/night_charging
```


These are the output you should expect:
```
1
-r--r--r-- 1 system system 4096 2025-09-17 20:14 /sys/class/qcom-battery/night_charging
```

**Note**: Date and time may differ, but the rest should be the same.

### What does the output mean?

`1` means the `/sys/class/qcom-battery/night_charging` is turned on. If the value is `0`, then it is off and charge limit wont work.

`-r--r--r--` means that the `/sys/class/qcom-battery/night_charging` is read-only for all users and groups, which prevents the system from reverting the value. If the value starts with `-rw-rw----`, then may not work since it will get reverted.


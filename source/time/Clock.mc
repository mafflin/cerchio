import Toybox.Lang;
import Toybox.System;

//! The one place time and device settings are read, once per update.
module Clock {

    const HOURS_PER_HALF_DAY = 12;
    const HOURS_PER_DAY = 24;
    const MINUTES_PER_HOUR = 60;
    const MINUTES_PER_DAY = HOURS_PER_DAY * MINUTES_PER_HOUR;
    const SECONDS_PER_MINUTE = 60;

    //! Null before the first read()
    var time as System.ClockTime? = null;
    var deviceSettings as System.DeviceSettings? = null;

    function read() as Void {
        readTime();
        deviceSettings = System.getDeviceSettings();
    }

    //! For partial updates
    function readTime() as Void {
        time = System.getClockTime();
    }

    function now() as System.ClockTime {
        if (time == null) {
            read();
        }

        return time as System.ClockTime;
    }

    function settings() as System.DeviceSettings {
        if (deviceSettings == null) {
            read();
        }

        return deviceSettings as System.DeviceSettings;
    }

    function minuteOfDay() as Number {
        var clockTime = now();

        return (clockTime.hour * MINUTES_PER_HOUR) + clockTime.min;
    }

    function wrapMinutes(minutes as Number) as Number {
        return (minutes + MINUTES_PER_DAY) % MINUTES_PER_DAY;
    }

    function displayHour(hour as Number) as Number {
        if (settings().is24Hour) {
            return hour;
        }

        return twelveHour(hour);
    }

    function isMorning(hour as Number) as Boolean {
        return hour < HOURS_PER_HALF_DAY;
    }

    function twelveHour(hour as Number) as Number {
        var onFace = hour % HOURS_PER_HALF_DAY;

        return (onFace == 0) ? HOURS_PER_HALF_DAY : onFace;
    }
}

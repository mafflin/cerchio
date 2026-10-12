import Toybox.Lang;

//! Opens once per minute, by Clock's last read.
class MinuteGate {

    private const NO_MINUTE = -1;

    private var lastMinute as Number = NO_MINUTE;

    function initialize() {
    }

    function opens() as Boolean {
        var minute = Clock.minuteOfDay();

        if (minute == lastMinute) {
            return false;
        }

        lastMinute = minute;

        return true;
    }
}

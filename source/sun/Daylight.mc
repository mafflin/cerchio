import Toybox.Complications;
import Toybox.Lang;

//! Today's sunrise, sunset and solar noon, off the complications. Read once a minute.
class Daylight {

    //! Minutes past midnight, null when the watch has no answer
    private var sunriseMinute as Number? = null;
    private var sunsetMinute as Number? = null;

    private var sunriseId as Complications.Id;
    private var sunsetId as Complications.Id;
    private var minuteGate as MinuteGate;

    function initialize() {
        sunriseId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNRISE);
        sunsetId = new Complications.Id(Complications.COMPLICATION_TYPE_SUNSET);
        minuteGate = new MinuteGate();
    }

    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        sunriseMinute = minutesOf(sunriseId);
        sunsetMinute = minutesOf(sunsetId);
    }

    function sunrise() as Number? {
        return sunriseMinute;
    }

    function sunset() as Number? {
        return sunsetMinute;
    }

    //! Solar noon, halfway from sunrise to sunset; null with either unknown
    function zenith() as Number? {
        var rise = sunriseMinute;
        var set = sunsetMinute;

        if ((rise == null) || (set == null)) {
            return null;
        }

        // The day may run across midnight.
        var length = (set - rise + Dial.MINUTES_PER_DAY) % Dial.MINUTES_PER_DAY;

        return (rise + (length / 2)) % Dial.MINUTES_PER_DAY;
    }

    //! The complication carries seconds past midnight
    private function minutesOf(id as Complications.Id) as Number? {
        // Some watches throw on a complication they do not carry.
        try {
            var seconds = secondsOf(Complications.getComplication(id).value);

            if (seconds == null) {
                return null;
            }

            return seconds / Clock.SECONDS_PER_MINUTE;
        } catch (exception) {
            return null;
        }
    }

    //! Null if not a number at all
    private function secondsOf(value as Complications.Value?) as Number? {
        if (value instanceof Lang.Number) {
            return value;
        }

        if (value instanceof Lang.Float) {
            return value.toNumber();
        }

        if (value instanceof Lang.Double) {
            return value.toNumber();
        }

        return null;
    }
}

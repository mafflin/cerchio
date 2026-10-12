import Toybox.Complications;
import Toybox.Lang;

//! Next sunrise or sunset; the system sunset until the dial knows
class SunKind extends FieldKind {

    private const CLOCK_FORMAT = "$1$:$2$";

    private var risingIcon as Icon;
    private var settingIcon as Icon;
    private var zenithIcon as Icon;

    private var isUp as Boolean = true;
    private var isTwilight as Boolean = false;
    private var isZenith as Boolean = false;

    function initialize() {
        FieldKind.initialize(null);
        risingIcon = new Icon(Rez.Drawables.Sunrise);
        settingIcon = new Icon(Rez.Drawables.Sunset);
        zenithIcon = new Icon(Rez.Drawables.Zenith);
    }

    function icon() as Icon? {
        if (isZenith) {
            return zenithIcon;
        }

        return isUp ? settingIcon : risingIcon;
    }

    function iconTint(color as Number) as Number {
        if (isZenith) {
            return DayColors.DAY;
        }

        return isTwilight ? DayColors.TWILIGHT : color;
    }

    function followsClock() as Boolean {
        return true;
    }

    function text(complication as Complications.Complication) as String {
        var daylight = Sun.daylight();
        var minute = Clock.minuteOfDay();
        var up = daylight.isUpAt(minute);

        if (up == null) {
            isUp = true;
            isTwilight = false;
            isZenith = false;
            return FieldKind.text(complication);
        }

        isUp = up;
        isTwilight = daylight.isTwilightAt(minute);
        isZenith = daylight.isZenithAt(minute);

        return clockOf((up ? daylight.sunset() : daylight.sunrise()) as Number);
    }

    //! Seconds past midnight
    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        return clockOf(ValueFormat.wholeNumber(value) / Clock.SECONDS_PER_MINUTE);
    }

    private function clockOf(minuteOfDay as Number) as String {
        var hour = Clock.displayHour(minuteOfDay / Clock.MINUTES_PER_HOUR);

        return ValueFormat.pair(CLOCK_FORMAT, hour, minuteOfDay % Clock.MINUTES_PER_HOUR);
    }
}

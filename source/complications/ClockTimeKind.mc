import Toybox.Complications;
import Toybox.Lang;

//! Seconds since midnight as H:MM by the 12/24 hour setting: sunrise and
//! sunset
class ClockTimeKind extends FieldKind {

    private const CLOCK_FORMAT = "$1$:$2$";

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        var secondsOfDay = ValueFormat.wholeNumber(value);
        var hour = Clock.displayHour(secondsOfDay / Clock.SECONDS_PER_HOUR);
        var minute = (secondsOfDay % Clock.SECONDS_PER_HOUR) / Clock.SECONDS_PER_MINUTE;

        return ValueFormat.pair(CLOCK_FORMAT, hour, minute);
    }
}

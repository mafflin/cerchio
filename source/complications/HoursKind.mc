import Toybox.Complications;
import Toybox.Lang;

//! Comes in minutes, despite older docs; shown as hours rounded up
class HoursKind extends FieldKind {

    private const HOUR = "h";

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        var minutes = ValueFormat.wholeNumber(value);
        var hours = (minutes + Clock.MINUTES_PER_HOUR - 1) / Clock.MINUTES_PER_HOUR;

        return hours.format(ValueFormat.LEADING_FORMAT) + HOUR;
    }
}

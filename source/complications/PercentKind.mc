import Toybox.Complications;
import Toybox.Lang;

class PercentKind extends FieldKind {

    private const PERCENT = "%";

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        return ValueFormat.whole(value) + PERCENT;
    }
}

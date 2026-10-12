import Toybox.Complications;
import Toybox.Lang;

//! Always comes in Celsius
class TemperatureKind extends FieldKind {

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        return ValueFormat.temperature(ValueFormat.decimal(value));
    }
}

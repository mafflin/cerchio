import Toybox.Complications;
import Toybox.Lang;

//! How a field shows one complication type: icon and text
class FieldKind {

    private var fieldIcon as Icon?;

    function initialize(resourceId as ResourceId?) {
        fieldIcon = (resourceId != null) ? new Icon(resourceId) : null;
    }

    function icon() as Icon? {
        return fieldIcon;
    }

    function iconTint(color as Number) as Number {
        return color;
    }

    //! Read again every minute
    function followsClock() as Boolean {
        return false;
    }

    function text(complication as Complications.Complication) as String {
        var value = complication.value;

        return (value != null) ? format(value, complication) : ValueFormat.NOTHING;
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        return ValueFormat.withUnit(value, complication.unit);
    }
}

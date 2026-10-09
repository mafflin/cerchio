import Toybox.Complications;
import Toybox.Lang;

//! How a data field shows one kind of complication: its icon, and its value
//! as text. This base shows the value as the system gives it, with any unit
//! it supplies as a string; a subclass formats its own kind. FieldKinds
//! picks one per type.
class FieldKind {

    private var fieldIcon as Icon?;

    //! resourceId null for no icon
    function initialize(resourceId as ResourceId?) {
        fieldIcon = (resourceId != null) ? new Icon(resourceId) : null;
    }

    function icon() as Icon? {
        return fieldIcon;
    }

    //! Empty when the system has no value
    function text(complication as Complications.Complication) as String {
        var value = complication.value;

        return (value != null) ? format(value, complication) : ValueFormat.NOTHING;
    }

    //! Overridden per kind
    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        return ValueFormat.withUnit(value, complication.unit);
    }
}

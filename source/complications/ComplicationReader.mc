import Toybox.Complications;
import Toybox.Lang;

//! Some watches throw on a complication they lack
module ComplicationReader {

    function read(id as Complications.Id) as Complications.Complication? {
        try {
            return Complications.getComplication(id);
        } catch (exception) {
            return null;
        }
    }

    function valueOf(id as Complications.Id) as Complications.Value? {
        var complication = read(id);

        return (complication != null) ? complication.value : null;
    }
}

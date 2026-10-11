import Toybox.Complications;
import Toybox.Lang;

//! What the tests hand the code under test; left out of release builds
(:debug)
module Probe {

    //! A real complication, for a FieldKind's format(), which the kinds
    //! tested never read: the battery, which every watch carries
    function complication() as Complications.Complication {
        return Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
    }
}

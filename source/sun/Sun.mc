import Toybox.Lang;

//! The shared Daylight; only the view refreshes it
module Sun {

    var shared as Daylight? = null;

    function daylight() as Daylight {
        if (shared == null) {
            shared = new Daylight();
        }

        return shared as Daylight;
    }
}

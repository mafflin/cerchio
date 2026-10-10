import Toybox.Lang;
import Toybox.Weather;

//! The weather the phone last sent, for the weather field, the wind and the
//! latitude: one read a minute between them, and a fresh one on waking or
//! coming back to the face, and while a weather field shows, whenever the
//! system says the weather has changed.
module CurrentWeather {

    //! Made on the first ask
    var readGate as MinuteGate? = null;
    var latest as Weather.CurrentConditions? = null;

    //! Null on a watch without weather, or before the phone has sent any
    function conditions() as Weather.CurrentConditions? {
        if (gate().opens()) {
            latest = (Toybox has :Weather) ? Weather.getCurrentConditions() : null;
        }

        return latest;
    }

    //! The next ask reads afresh
    function invalidate() as Void {
        gate().reset();
    }

    function gate() as MinuteGate {
        if (readGate == null) {
            readGate = new MinuteGate();
        }

        return readGate as MinuteGate;
    }
}

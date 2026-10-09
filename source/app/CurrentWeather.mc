import Toybox.Lang;
import Toybox.Weather;

//! The weather the phone last sent, for the weather field and the latitude
module CurrentWeather {

    //! Null on a watch without weather, or before the phone has sent any
    function conditions() as Weather.CurrentConditions? {
        if (!(Toybox has :Weather)) {
            return null;
        }

        return Weather.getCurrentConditions();
    }
}

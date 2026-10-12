import Toybox.Lang;
import Toybox.Weather;

module CurrentWeather {

    //! Null without weather support or data
    function conditions() as Weather.CurrentConditions? {
        if (!(Toybox has :Weather)) {
            return null;
        }

        return Weather.getCurrentConditions();
    }
}

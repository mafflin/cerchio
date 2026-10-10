import Toybox.Activity;
import Toybox.Lang;
import Toybox.Position;

//! Where on earth the watch is, north to south: the weather's location, or
//! the last fix. Degrees, north positive.
module Latitude {

    //! Null with neither
    function read() as Float? {
        var latitude = weatherLatitude();

        return (latitude != null) ? latitude : lastFixLatitude();
    }

    //! Null on a watch without weather, or before the phone has sent any
    function weatherLatitude() as Float? {
        var conditions = CurrentWeather.conditions();

        if (conditions == null) {
            return null;
        }

        return latitudeOf(conditions.observationLocationPosition);
    }

    //! Null without a fix
    function lastFixLatitude() as Float? {
        var info = Activity.getActivityInfo();

        return (info != null) ? latitudeOf(info.currentLocation) : null;
    }

    //! Null without a location
    function latitudeOf(location as Position.Location?) as Float? {
        if (location == null) {
            return null;
        }

        return location.toDegrees()[0].toFloat();
    }
}

import Toybox.Lang;
import Toybox.Position;

//! Degrees, north positive: weather location, else last fix. Needs the
//! Positioning permission.
module Latitude {

    function read() as Float? {
        var latitude = weatherLatitude();

        return (latitude != null) ? latitude : lastFixLatitude();
    }

    function weatherLatitude() as Float? {
        var conditions = CurrentWeather.conditions();

        if (conditions == null) {
            return null;
        }

        return latitudeOf(conditions.observationLocationPosition);
    }

    //! However old; null without a fix since boot
    function lastFixLatitude() as Float? {
        var info = Position.getInfo();

        if (info.accuracy == Position.QUALITY_NOT_AVAILABLE) {
            return null;
        }

        return latitudeOf(info.position);
    }

    function latitudeOf(location as Position.Location?) as Float? {
        if (location == null) {
            return null;
        }

        return location.toDegrees()[0].toFloat();
    }
}

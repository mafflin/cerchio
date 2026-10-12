import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;

//! Civil dawn and dusk, which Garmin doesn't give
module Twilight {

    //! Degrees
    const ALTITUDE = -6.0;

    //! Degrees, refraction included
    const HORIZON = -0.833;

    //! Degrees; near an equinox day length doesn't tell the latitude
    const MIN_DECLINATION = 2.0;

    //! Degrees
    const TILT = 23.44;

    const DAYS_PER_YEAR = 365.0;

    //! Days from the winter solstice to January 1st
    const SOLSTICE_LEAD = 10;

    const MINUTES_PER_DEGREE = 4.0;

    const HALF_DAY_DEGREES = 180.0;

    //! Leap years ignored
    const DAYS_BEFORE_MONTH = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

    //! Dawn to noon; sunDeclination in radians. Null without a latitude or
    //! twilight; half a day on a white night.
    function minutesFromNoon(dayLength as Number, latitudeDegrees as Float?, sunDeclination as Decimal) as Number? {
        var latitude = latitudeOf(latitudeDegrees, dayLength, sunDeclination);

        if (latitude == null) {
            return null;
        }

        var hourAngle = hourAngleOf(latitude, sunDeclination);

        if (hourAngle == null) {
            return null;
        }

        return (hourAngle * MINUTES_PER_DEGREE).toNumber();
    }

    //! Radians; falls back to the day's length
    function latitudeOf(degrees as Float?, dayLength as Number, sunDeclination as Decimal) as Decimal? {
        if (degrees != null) {
            return Math.toRadians(degrees);
        }

        return latitudeFromDayLength(dayLength, sunDeclination);
    }

    //! Radians. Solves cos(h)·cos(d)·cos(lat) + sin(d)·sin(lat) = sin(HORIZON).
    function latitudeFromDayLength(dayLength as Number, sunDeclination as Decimal) as Decimal? {
        if (Math.toDegrees(sunDeclination).abs() < MIN_DECLINATION) {
            return null;
        }

        var hourAngle = Math.toRadians(dayLength / 2.0 / MINUTES_PER_DEGREE);
        var cosineTerm = Math.cos(hourAngle) * Math.cos(sunDeclination);
        var sineTerm = Math.sin(sunDeclination);
        var ratio = Math.sin(Math.toRadians(HORIZON)) / Math.sqrt((cosineTerm * cosineTerm) + (sineTerm * sineTerm));

        if (ratio.abs() > 1) {
            return null;
        }

        var middle = Math.atan2(sineTerm, cosineTerm);
        var spread = Math.acos(ratio);
        var latitude = middle + spread;

        return (latitude.abs() <= (Math.PI / 2)) ? latitude : (middle - spread);
    }

    //! Degrees from noon to ALTITUDE; null if never that high
    function hourAngleOf(latitude as Decimal, sunDeclination as Decimal) as Decimal? {
        var cosine = (Math.sin(Math.toRadians(ALTITUDE)) - (Math.sin(latitude) * Math.sin(sunDeclination)))
            / (Math.cos(latitude) * Math.cos(sunDeclination));

        if (cosine < -1) {
            return HALF_DAY_DEGREES;
        }

        if (cosine > 1) {
            return null;
        }

        return Math.toDegrees(Math.acos(cosine));
    }

    //! Radians
    function declination() as Decimal {
        var turn = 2 * Math.PI * (dayOfYear() + SOLSTICE_LEAD) / DAYS_PER_YEAR;

        return -Math.toRadians(TILT) * Math.cos(turn);
    }

    //! 0 on January 1st
    function dayOfYear() as Number {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        return (DAYS_BEFORE_MONTH[(today.month as Number) - 1] as Number) + today.day - 1;
    }
}

import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;

//! Twilight's math against known values. The declination is given rather
//! than taken from today, so the results do not depend on the date.
(:test)
module TwilightTest {

    //! Degrees a latitude worked back from a whole minute day length may be
    //! off by
    const LATITUDE_TOLERANCE = 1.0;

    //! Degrees
    const HOUR_ANGLE_TOLERANCE = 0.01;

    //! At an equinox on the equator the sun drops straight down: 6° below the
    //! horizon 96° from noon, 6 h 24 min either side
    (:test)
    function equinoxOnEquator(logger as Test.Logger) as Boolean {
        var hourAngle = Twilight.hourAngleOf(0.0, 0.0);

        logger.debug("hour angle " + hourAngle);
        Approx.check(Approx.isNear(hourAngle, 96.0, HOUR_ANGLE_TOLERANCE), "96° from noon");

        return true;
    }

    //! 65° north at the June solstice the sun never gets 6° down
    (:test)
    function whiteNight(logger as Test.Logger) as Boolean {
        var hourAngle = Twilight.hourAngleOf(Math.toRadians(65.0), Math.toRadians(Twilight.TILT));

        Approx.check(Approx.isNear(hourAngle, Twilight.HALF_DAY_DEGREES, HOUR_ANGLE_TOLERANCE), "round to midnight");

        return true;
    }

    //! 80° north at the December solstice the sun never climbs to 6° down
    (:test)
    function polarNight(logger as Test.Logger) as Boolean {
        var hourAngle = Twilight.hourAngleOf(Math.toRadians(80.0), Math.toRadians(-Twilight.TILT));

        Approx.check(hourAngle == null, "no twilight");

        return true;
    }

    //! A known latitude wins over the day's length
    (:test)
    function knownLatitudeWins(logger as Test.Logger) as Boolean {
        var degrees = 52.5;
        var latitude = Twilight.latitudeOf(degrees, Clock.MINUTES_PER_DAY / 2, Math.toRadians(Twilight.TILT));

        Approx.check(Approx.isNear(latitude, Math.toRadians(degrees), 0.0001), "the latitude given");

        return true;
    }

    //! The day's length of a latitude gives that latitude back, on either
    //! side of the equator and of an equinox
    (:test)
    function latitudeFromDayLength(logger as Test.Logger) as Boolean {
        var latitudes = [-50.0, -20.0, 0.0, 30.0, 52.5, 60.0] as Array<Float>;
        var declinations = [Twilight.TILT, -15.0, 10.0] as Array<Float>;

        for (var d = 0; d < declinations.size(); d++) {
            var declination = Math.toRadians(declinations[d]);

            for (var l = 0; l < latitudes.size(); l++) {
                var expected = latitudes[l];
                var dayLength = dayLengthAt(expected, declination);
                var latitude = Twilight.latitudeFromDayLength(dayLength, declination);
                var degrees = (latitude != null) ? Math.toDegrees(latitude) : null;

                logger.debug("declination " + declinations[d] + "°, " + expected + "°: day "
                    + dayLength + " min, worked back " + degrees);
                Approx.check(Approx.isNear(degrees, expected, LATITUDE_TOLERANCE),
                    "latitude " + expected + "° at declination " + declinations[d] + "°");
            }
        }

        return true;
    }

    //! Too close to an equinox the day's length says nothing
    (:test)
    function noLatitudeNearEquinox(logger as Test.Logger) as Boolean {
        var latitude = Twilight.latitudeFromDayLength(Clock.MINUTES_PER_DAY / 2, Math.toRadians(1.0));

        Approx.check(latitude == null, "no latitude");

        return true;
    }

    //! Minutes from sunrise to sunset, rounded like the complications'
    (:debug)
    function dayLengthAt(latitudeDegrees as Float, declination as Decimal) as Number {
        var latitude = Math.toRadians(latitudeDegrees);
        var cosine = (Math.sin(Math.toRadians(Twilight.HORIZON)) - (Math.sin(latitude) * Math.sin(declination)))
            / (Math.cos(latitude) * Math.cos(declination));
        var hourAngle = Math.toDegrees(Math.acos(cosine));

        return Numbers.round(2 * hourAngle * Twilight.MINUTES_PER_DEGREE);
    }
}

import Toybox.Lang;
import Toybox.Position;
import Toybox.Test;

//! Where the latitude comes from. In the simulator, set weather and a
//! position (Simulation > Set Position) to see each source come in.
(:test)
module LatitudeTest {

    const TOLERANCE = 0.0001;

    (:test)
    function noLocation(logger as Test.Logger) as Boolean {
        Approx.check(Latitude.latitudeOf(null) == null, "null without a location");

        return true;
    }

    (:test)
    function fromLocation(logger as Test.Logger) as Boolean {
        var location = new Position.Location({
            :latitude => -33.9,
            :longitude => 18.4,
            :format => :degrees
        });

        Approx.check(Approx.isNear(Latitude.latitudeOf(location), -33.9, TOLERANCE), "south negative");

        return true;
    }

    //! The weather's location first, the last fix without it. Logs what the
    //! simulator or watch has: null for both means twilight falls back on
    //! the day's length.
    (:test)
    function weatherFirst(logger as Test.Logger) as Boolean {
        var weather = Latitude.weatherLatitude();
        var fix = Latitude.lastFixLatitude();
        var read = Latitude.read();

        logger.debug("weather " + weather + ", last fix " + fix + ", read " + read);
        Approx.check(Approx.isSame(read, (weather != null) ? weather : fix, TOLERANCE), "weather, else the fix");

        return true;
    }

    //! Weather that came in comes with where it was observed: without the
    //! Positioning permission it comes without, and twilight never gets a
    //! latitude. Passes on a watch or simulator without weather.
    (:test)
    function weatherHasPosition(logger as Test.Logger) as Boolean {
        var conditions = CurrentWeather.conditions();

        if (conditions == null) {
            logger.warning("no weather to check: set it in the simulator");

            return true;
        }

        var position = conditions.observationLocationPosition;

        logger.debug("weather position " + ((position != null) ? position.toDegrees() : null));
        Approx.check(position != null, "the weather's position; is the Positioning permission there?");

        return true;
    }

    //! Null until the watch has a fix (Simulation > Set Position), then on
    //! the globe
    (:test)
    function lastFix(logger as Test.Logger) as Boolean {
        var accuracy = Position.getInfo().accuracy;
        var fix = Latitude.lastFixLatitude();

        logger.debug("accuracy " + accuracy + ", last fix " + fix);

        if (accuracy == Position.QUALITY_NOT_AVAILABLE) {
            Approx.check(fix == null, "no fix");
        } else if (fix != null) {
            Approx.check(fix.abs() <= 90.0, "on the globe");
        }

        return true;
    }
}

import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

//! The kinds that follow the watch's units. Each checks the unit the
//! simulator is set to; switch units and run again for the other.
(:test)
module UnitKindsTest {

    //! Meters in
    (:test)
    function altitude(logger as Test.Logger) as Boolean {
        var kind = new AltitudeKindProbe();
        var isFeet = Clock.settings().elevationUnits == System.UNIT_STATUTE;

        logger.debug("feet: " + isFeet);
        Approx.checkEqual(kind.formatted(100), isFeet ? "328" : "100", "100 m");
        Approx.checkEqual(kind.formatted(-12.6), isFeet ? "-41" : "-13", "below the sea");

        return true;
    }

    //! Meters in, one decimal out
    (:test)
    function distance(logger as Test.Logger) as Boolean {
        var kind = new DistanceKindProbe();
        var isMiles = Clock.settings().distanceUnits == System.UNIT_STATUTE;

        logger.debug("miles: " + isMiles);
        Approx.checkEqual(kind.formatted(5000), isMiles ? "3.1" : "5.0", "5 km");
        Approx.checkEqual(kind.formatted(0), "0.0", "none");

        return true;
    }

    //! Celsius in
    (:test)
    function temperature(logger as Test.Logger) as Boolean {
        var kind = new TemperatureKindProbe();
        var isFahrenheit = Clock.settings().temperatureUnits == System.UNIT_STATUTE;

        logger.debug("Fahrenheit: " + isFahrenheit);
        Approx.checkEqual(kind.formatted(21.4), isFahrenheit ? "71°" : "21°", "21.4 °C");
        Approx.checkEqual(kind.formatted(-5), isFahrenheit ? "23°" : "-5°", "-5 °C");

        return true;
    }
}

(:debug)
class AltitudeKindProbe extends AltitudeKind {

    function initialize() {
        AltitudeKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

(:debug)
class DistanceKindProbe extends DistanceKind {

    function initialize() {
        DistanceKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

(:debug)
class TemperatureKindProbe extends TemperatureKind {

    function initialize() {
        TemperatureKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

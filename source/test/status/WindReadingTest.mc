import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

//! Speeds in m/s
(:test)
module WindReadingTest {

    const LIGHT = Graphics.COLOR_WHITE;

    (:test)
    function strength(logger as Test.Logger) as Boolean {
        var reading = new WindReading();

        Approx.checkEqual(reading.colorAt(null, LIGHT), LIGHT, "no speed is light");
        Approx.checkEqual(reading.colorAt(0, LIGHT), LIGHT, "still");
        Approx.checkEqual(reading.colorAt(5.0, LIGHT), LIGHT, "18 km/h");
        Approx.checkEqual(reading.colorAt(5.5, LIGHT), LIGHT, "19.8 km/h");
        Approx.checkEqual(reading.colorAt(5.6, LIGHT), Palette.AMBER, "20.2 km/h");
        Approx.checkEqual(reading.colorAt(11.1, LIGHT), Palette.AMBER, "40.0 km/h");
        Approx.checkEqual(reading.colorAt(11.2, LIGHT), Palette.ORANGE, "40.3 km/h");
        Approx.checkEqual(reading.colorAt(30, LIGHT), Palette.ORANGE, "108 km/h");

        return true;
    }

    (:test)
    function calm(logger as Test.Logger) as Boolean {
        var reading = new WindReading();

        Approx.check(reading.isCalmAt(0), "still");
        Approx.check(reading.isCalmAt(0.1), "0.36 km/h");
        Approx.check(!reading.isCalmAt(0.2), "0.72 km/h");
        Approx.check(!reading.isCalmAt(null), "no speed is not calm");

        return true;
    }
}

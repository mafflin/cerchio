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
        Approx.checkEqual(reading.colorAt(5.6, LIGHT), DayColors.NIGHT, "20.2 km/h");
        Approx.checkEqual(reading.colorAt(10.8, LIGHT), DayColors.NIGHT, "38.9 km/h");
        Approx.checkEqual(reading.colorAt(10.9, LIGHT), DayColors.DAY, "39.2 km/h");
        Approx.checkEqual(reading.colorAt(17.2, LIGHT), DayColors.DAY, "61.9 km/h");
        Approx.checkEqual(reading.colorAt(17.3, LIGHT), DayColors.TWILIGHT, "62.3 km/h");
        Approx.checkEqual(reading.colorAt(33, LIGHT), DayColors.TWILIGHT, "118.8 km/h");

        return true;
    }

    (:test)
    function calm(logger as Test.Logger) as Boolean {
        var reading = new WindReading();

        Approx.check(reading.isCalmAt(0), "still");
        Approx.check(reading.isCalmAt(0.2), "0.72 km/h");
        Approx.check(!reading.isCalmAt(0.3), "1.08 km/h");
        Approx.check(!reading.isCalmAt(null), "no speed is not calm");

        return true;
    }
}

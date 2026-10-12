import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

(:test)
module ValueFormatTest {

    (:test)
    function decimal(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.decimal(3), 3.0, "a number");
        Approx.checkEqual(ValueFormat.decimal(2.5), 2.5, "a float");
        Approx.checkEqual(ValueFormat.decimal(2.5d), 2.5, "a double");
        Approx.checkEqual(ValueFormat.decimal(5l), 5.0, "a long");
        Approx.checkEqual(ValueFormat.decimal("12"), 0.0, "a string");

        return true;
    }

    (:test)
    function wholeNumber(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.wholeNumber(7), 7, "a number");
        Approx.checkEqual(ValueFormat.wholeNumber(7.9), 7, "a float");
        Approx.checkEqual(ValueFormat.wholeNumber(7l), 7, "a long");
        Approx.checkEqual(ValueFormat.wholeNumber("7"), 0, "a string");

        return true;
    }

    (:test)
    function number(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.number(5), "5", "a number");
        Approx.checkEqual(ValueFormat.number(2.0), "2.0", "a whole float");
        Approx.checkEqual(ValueFormat.number(2.26), "2.3", "a float");
        Approx.checkEqual(ValueFormat.number(2.26d), "2.3", "a double");
        Approx.checkEqual(ValueFormat.number("abc"), "abc", "a string");

        return true;
    }

    (:test)
    function withUnit(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.withUnit(5, "km"), "5km", "a string");
        Approx.checkEqual(ValueFormat.withUnit(5, ""), "5", "an empty string");
        Approx.checkEqual(ValueFormat.withUnit(5, null), "5", "none");
        Approx.checkEqual(ValueFormat.withUnit(5, Complications.UNIT_TEMPERATURE), "5", "a system unit");

        return true;
    }

    (:test)
    function pair(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.pair("$1$:$2$", 7, 5), "7:05", "padded");
        Approx.checkEqual(ValueFormat.pair("$1$:$2$", 12, 30), "12:30", "two digits");

        return true;
    }

    (:test)
    function roundedAndWhole(logger as Test.Logger) as Boolean {
        Approx.checkEqual(ValueFormat.rounded(2.5), "3", "half up");
        Approx.checkEqual(ValueFormat.rounded(-2.4), "-2", "negative");
        Approx.checkEqual(ValueFormat.rounded(-0.4), "0", "no minus zero");
        Approx.checkEqual(ValueFormat.whole(87.6), "88", "a float");
        Approx.checkEqual(ValueFormat.whole("x"), "0", "a string");

        return true;
    }

    (:test)
    function temperature(logger as Test.Logger) as Boolean {
        var isFahrenheit = Clock.settings().temperatureUnits == System.UNIT_STATUTE;

        logger.debug("Fahrenheit: " + isFahrenheit);
        Approx.checkEqual(ValueFormat.temperature(21.4), isFahrenheit ? "71°" : "21°", "21.4 °C");
        Approx.checkEqual(ValueFormat.temperature(-0.4), isFahrenheit ? "31°" : "0°", "-0.4 °C");

        return true;
    }
}

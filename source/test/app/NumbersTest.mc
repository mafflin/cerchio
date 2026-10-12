import Toybox.Lang;
import Toybox.Test;

(:test)
module NumbersTest {

    (:test)
    function minAndMax(logger as Test.Logger) as Boolean {
        Approx.checkEqual(Numbers.min(3, 7), 3, "min");
        Approx.checkEqual(Numbers.min(-2, -5), -5, "min of negatives");
        Approx.checkEqual(Numbers.max(3, 7), 7, "max");
        Approx.checkEqual(Numbers.max(4, 4), 4, "max of equals");

        return true;
    }

    (:test)
    function round(logger as Test.Logger) as Boolean {
        Approx.checkEqual(Numbers.round(2.4), 2, "2.4");
        Approx.checkEqual(Numbers.round(2.5), 3, "2.5");
        Approx.checkEqual(Numbers.round(-2.6), -3, "-2.6");
        Approx.checkEqual(Numbers.round(-0.4), 0, "-0.4");

        return true;
    }

    (:test)
    function isBetweenWithin(logger as Test.Logger) as Boolean {
        Approx.check(Numbers.isBetween(5, 1, 10), "inside");
        Approx.check(Numbers.isBetween(1, 1, 10), "from is in");
        Approx.check(!Numbers.isBetween(10, 1, 10), "to is out");
        Approx.check(!Numbers.isBetween(0, 1, 10), "before");
        Approx.check(!Numbers.isBetween(4, 4, 4), "an empty span holds nothing");

        return true;
    }

    (:test)
    function isBetweenAcrossZero(logger as Test.Logger) as Boolean {
        var from = 22 * Clock.MINUTES_PER_HOUR;
        var to = 2 * Clock.MINUTES_PER_HOUR;

        Approx.check(Numbers.isBetween(23 * Clock.MINUTES_PER_HOUR, from, to), "before midnight");
        Approx.check(Numbers.isBetween(0, from, to), "midnight");
        Approx.check(Numbers.isBetween(60, from, to), "after midnight");
        Approx.check(Numbers.isBetween(from, from, to), "from is in");
        Approx.check(!Numbers.isBetween(to, from, to), "to is out");
        Approx.check(!Numbers.isBetween(12 * Clock.MINUTES_PER_HOUR, from, to), "noon");

        return true;
    }
}

import Toybox.Lang;
import Toybox.Test;

//! The time stays as Clock last read it until something reads again, so
//! within a test the minute does not move
(:test)
module MinuteGateTest {

    (:test)
    function opensOncePerMinute(logger as Test.Logger) as Boolean {
        var gate = new MinuteGate();

        Approx.check(gate.opens(), "first ask");
        Approx.check(!gate.opens(), "again in the same minute");
        Approx.check(!gate.opens(), "and again");

        return true;
    }

    (:test)
    function gatesAreApart(logger as Test.Logger) as Boolean {
        var first = new MinuteGate();
        var second = new MinuteGate();

        Approx.check(first.opens(), "the first");
        Approx.check(second.opens(), "the second, though the first opened");

        return true;
    }
}

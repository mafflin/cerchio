import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

(:test)
module HighLowKindTest {

    (:test)
    function pair(logger as Test.Logger) as Boolean {
        var kind = new HighLowKindProbe();

        Approx.checkEqual(kind.formatted("H 21 / L 12"), "H 21° / L 12°", "spaced");
        Approx.checkEqual(kind.formatted("21/12"), "21°/12°", "bare");
        Approx.checkEqual(kind.formatted("H -3 / L -10"), "H -3° / L -10°", "below zero");

        return true;
    }

    //! A separator followed by digits is a decimal point
    (:test)
    function decimals(logger as Test.Logger) as Boolean {
        var kind = new HighLowKindProbe();

        Approx.checkEqual(kind.formatted("21.5/12"), "21.5°/12°", "a point");
        Approx.checkEqual(kind.formatted("21,5"), "21,5°", "a comma");
        Approx.checkEqual(kind.formatted("21."), "21°.", "a point with nothing behind");

        return true;
    }

    (:test)
    function oneNumber(logger as Test.Logger) as Boolean {
        var kind = new HighLowKindProbe();

        Approx.checkEqual(kind.formatted(21), "21°", "a number");
        Approx.checkEqual(kind.formatted(21.6), "22°", "a float");

        return true;
    }
}

(:debug)
class HighLowKindProbe extends HighLowKind {

    function initialize() {
        HighLowKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

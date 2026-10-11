import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

(:test)
module PercentKindTest {

    (:test)
    function marked(logger as Test.Logger) as Boolean {
        var kind = new PercentKindProbe();

        Approx.checkEqual(kind.formatted(87), "87%", "a number");
        Approx.checkEqual(kind.formatted(87.6), "88%", "a float, rounded");
        Approx.checkEqual(kind.formatted(100), "100%", "full");

        return true;
    }
}

(:debug)
class PercentKindProbe extends PercentKind {

    function initialize() {
        PercentKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

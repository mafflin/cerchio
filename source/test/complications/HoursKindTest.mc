import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

//! Minutes in, whole hours rounded up out
(:test)
module HoursKindTest {

    (:test)
    function roundedUp(logger as Test.Logger) as Boolean {
        var kind = new HoursKindProbe();

        Approx.checkEqual(kind.formatted(0), "0h", "none");
        Approx.checkEqual(kind.formatted(1), "1h", "a minute counts as an hour");
        Approx.checkEqual(kind.formatted(60), "1h", "an hour");
        Approx.checkEqual(kind.formatted(61), "2h", "just past an hour");
        Approx.checkEqual(kind.formatted(2880), "48h", "two days");

        return true;
    }
}

(:debug)
class HoursKindProbe extends HoursKind {

    function initialize() {
        HoursKind.initialize(null);
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

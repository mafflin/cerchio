import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

//! The system's sunset, before the dial knows the sun: seconds past
//! midnight in, H:MM out by the 12/24 hour setting
(:test)
module SunKindTest {

    (:test)
    function clock(logger as Test.Logger) as Boolean {
        var kind = new SunKindProbe();
        var is24Hour = Clock.settings().is24Hour;

        logger.debug("24 hour: " + is24Hour);
        Approx.checkEqual(kind.formatted((18 * 3600) + (5 * 60)), is24Hour ? "18:05" : "6:05", "18:05");
        Approx.checkEqual(kind.formatted((7 * 3600) + (42 * 60) + 59), "7:42", "seconds dropped");

        return true;
    }

    (:test)
    function followsClock(logger as Test.Logger) as Boolean {
        Approx.check(new SunKindProbe().followsClock(), "read every minute");

        return true;
    }
}

(:debug)
class SunKindProbe extends SunKind {

    function initialize() {
        SunKind.initialize();
    }

    function formatted(value as Complications.Value) as String {
        return format(value, Probe.complication());
    }
}

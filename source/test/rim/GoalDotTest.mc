import Toybox.Lang;
import Toybox.Test;

//! Not started and done are both at the top
(:test)
module GoalDotTest {

    (:test)
    function degrees(logger as Test.Logger) as Boolean {
        var dot = new GoalDot();

        Approx.checkEqual(dot.degreesOf(0.0), 0, "not started");
        Approx.checkEqual(dot.degreesOf(0.25), 90, "a quarter");
        Approx.checkEqual(dot.degreesOf(0.5), 180, "halfway");
        Approx.checkEqual(dot.degreesOf(0.9986), 359, "a degree short");
        Approx.checkEqual(dot.degreesOf(0.9995), 0, "rounds back to the top");
        Approx.checkEqual(dot.degreesOf(1.0), 0, "done");

        return true;
    }
}

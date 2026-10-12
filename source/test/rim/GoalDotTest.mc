import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

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

    (:test)
    function color(logger as Test.Logger) as Boolean {
        var dot = new GoalDot();
        dot.setColor(Graphics.COLOR_WHITE);

        Approx.checkEqual(dot.colorOf(0.0), Graphics.COLOR_WHITE, "not started");
        Approx.checkEqual(dot.colorOf(0.5), Graphics.COLOR_WHITE, "halfway");
        Approx.checkEqual(dot.colorOf(0.9995), Graphics.COLOR_WHITE, "at the top, not yet done");
        Approx.checkEqual(dot.colorOf(1.0), DayColors.TWILIGHT, "done");
        Approx.checkEqual(dot.colorOf(1.5), DayColors.TWILIGHT, "past the goal");

        return true;
    }
}

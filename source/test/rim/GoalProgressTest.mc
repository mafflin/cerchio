import Toybox.Lang;
import Toybox.Test;

(:test)
module GoalProgressTest {

    (:test)
    function noGoal(logger as Test.Logger) as Boolean {
        var progress = new GoalProgress();

        Approx.check(progress.shareOf(500, null) == null, "no goal");
        Approx.check(progress.shareOf(500, 0) == null, "a zero goal");
        Approx.check(progress.shareOf(500, -1) == null, "a negative goal");
        Approx.check(progress.shareOf(null, 10000) == null, "no steps");

        return true;
    }

    (:test)
    function share(logger as Test.Logger) as Boolean {
        var progress = new GoalProgress();

        Approx.checkEqual(progress.shareOf(0, 10000) as Float, 0.0, "not started");
        Approx.checkEqual(progress.shareOf(5000, 10000) as Float, 0.5, "halfway");
        Approx.check(Approx.isNear(progress.shareOf(1, 3), 0.3333, 0.001), "a third");
        Approx.checkEqual(progress.shareOf(10000, 10000) as Float, 1.0, "done");
        Approx.checkEqual(progress.shareOf(25000, 10000) as Float, 1.0, "past the goal");

        return true;
    }
}

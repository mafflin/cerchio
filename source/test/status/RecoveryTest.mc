import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

(:test)
module RecoveryTest {

    (:test)
    function tints(logger as Test.Logger) as Boolean {
        var recovery = new Recovery();
        var plain = Graphics.COLOR_WHITE;

        Approx.checkEqual(recovery.tintFor(1, plain), plain, "a minute");
        Approx.checkEqual(recovery.tintFor(1440, plain), plain, "a day");
        Approx.checkEqual(recovery.tintFor(1441, plain), DayColors.NIGHT, "past a day");
        Approx.checkEqual(recovery.tintFor(2880, plain), DayColors.NIGHT, "two days");
        Approx.checkEqual(recovery.tintFor(2881, plain), DayColors.DAY, "past two days");
        Approx.checkEqual(recovery.tintFor(4320, plain), DayColors.DAY, "three days");
        Approx.checkEqual(recovery.tintFor(4321, plain), DayColors.TWILIGHT, "past three days");
        Approx.checkEqual(recovery.tintFor(5760, plain), DayColors.TWILIGHT, "four days");

        return true;
    }
}

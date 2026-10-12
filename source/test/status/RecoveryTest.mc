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
        Approx.checkEqual(recovery.tintFor(1441, plain), Palette.AMBER, "past a day");
        Approx.checkEqual(recovery.tintFor(2880, plain), Palette.AMBER, "two days");
        Approx.checkEqual(recovery.tintFor(2881, plain), Palette.ORANGE, "past two days");

        return true;
    }
}

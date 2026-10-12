import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

(:test)
module BatteryTest {

    (:test)
    function levels(logger as Test.Logger) as Boolean {
        var battery = new Battery();

        Approx.checkEqual(battery.levelOf(0.0), 0, "empty");
        Approx.checkEqual(battery.levelOf(9.9), 0, "under 10%");
        Approx.checkEqual(battery.levelOf(10.0), 1, "10%");
        Approx.checkEqual(battery.levelOf(55.0), 5, "55%");
        Approx.checkEqual(battery.levelOf(99.9), 9, "not quite full");
        Approx.checkEqual(battery.levelOf(100.0), 10, "full");
        Approx.checkEqual(battery.levelOf(-5.0), 0, "below empty");
        Approx.checkEqual(battery.levelOf(120.0), 10, "above full");

        return true;
    }

    (:test)
    function tints(logger as Test.Logger) as Boolean {
        var battery = new Battery();
        var plain = Graphics.COLOR_WHITE;

        Approx.checkEqual(battery.tintFor(0, plain), Palette.ORANGE, "empty");
        Approx.checkEqual(battery.tintFor(1, plain), Palette.AMBER, "low");
        Approx.checkEqual(battery.tintFor(2, plain), plain, "20%");
        Approx.checkEqual(battery.tintFor(10, plain), plain, "full");

        return true;
    }
}

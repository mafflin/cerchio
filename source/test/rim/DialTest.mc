import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;

//! Positions are degrees clockwise from the top; midnight is at the bottom
(:test)
module DialTest {

    const TOLERANCE = 0.001;

    //! The rim is the smaller half
    (:test)
    function setup(logger as Test.Logger) as Boolean {
        var bitmap = Graphics.createBufferedBitmap({ :width => 260, :height => 200 }).get() as Graphics.BufferedBitmap;

        Dial.setup(bitmap.getDc());

        Approx.checkEqual(Dial.screenWidth, 260, "width");
        Approx.checkEqual(Dial.screenHeight, 200, "height");
        Approx.checkEqual(Dial.centerX, 130, "center x");
        Approx.checkEqual(Dial.centerY, 100, "center y");
        Approx.checkEqual(Dial.rim, 100, "rim");
        Approx.checkEqual(Dial.air, 100 / Dial.AIR_DIVISOR, "air");

        return true;
    }

    (:test)
    function positionOfMinute(logger as Test.Logger) as Boolean {
        Approx.check(Approx.isNear(Dial.positionOfMinute(0), 180.0, TOLERANCE), "midnight at the bottom");
        Approx.check(Approx.isNear(Dial.positionOfMinute(6 * 60), 270.0, TOLERANCE), "06:00 on the left");
        Approx.check(Approx.isNear(Dial.positionOfMinute(12 * 60), 0.0, TOLERANCE), "noon at the top");
        Approx.check(Approx.isNear(Dial.positionOfMinute(18 * 60), 90.0, TOLERANCE), "18:00 on the right");
        Approx.check(Approx.isNear(Dial.positionOfMinute(Clock.MINUTES_PER_DAY - 1), 179.75, TOLERANCE), "23:59 just before the bottom");

        return true;
    }

    (:test)
    function radiansOf(logger as Test.Logger) as Boolean {
        Approx.check(Approx.isNear(Dial.radiansOf(0), Math.PI / 2, TOLERANCE), "the top");
        Approx.check(Approx.isNear(Dial.radiansOf(90), 0.0, TOLERANCE), "the right");

        return true;
    }

    //! Screen y grows downward
    (:test)
    function points(logger as Test.Logger) as Boolean {
        Dial.centerX = 100;
        Dial.centerY = 100;

        checkPoint(0, 100, 50, "top");
        checkPoint(90, 150, 100, "right");
        checkPoint(180, 100, 150, "bottom");
        checkPoint(270, 50, 100, "left");

        return true;
    }

    (:debug)
    function checkPoint(position as Number, x as Number, y as Number, name as String) as Void {
        var radians = Dial.radiansOf(position);

        Approx.checkEqual(Dial.pointX(radians, 50), x, name + " x");
        Approx.checkEqual(Dial.pointY(radians, 50), y, name + " y");
    }
}

import Toybox.Lang;
import Toybox.Test;

(:test)
module FaceBufferTest {

    (:test)
    function nothingBeforeTheFirstDraw(logger as Test.Logger) as Boolean {
        var buffer = new FaceBuffer();

        Approx.check(!buffer.isCurrent(5), "not current");
        Approx.check(buffer.lastDrawn() == null, "no last drawn face");

        return true;
    }

    (:test)
    function currentForTheMinuteDrawn(logger as Test.Logger) as Boolean {
        var buffer = new FaceBuffer();

        buffer.markDrawn(5);
        Approx.check(buffer.isCurrent(5), "the minute drawn");
        Approx.check(!buffer.isCurrent(6), "the next minute");

        buffer.invalidate();
        Approx.check(!buffer.isCurrent(5), "after invalidate");

        return true;
    }

    (:test)
    function bitmapAndLastDrawn(logger as Test.Logger) as Boolean {
        var buffer = new FaceBuffer();

        Dial.screenWidth = 100;
        Dial.screenHeight = 100;

        Approx.check(buffer.bitmap() != null, "a bitmap");
        Approx.check(buffer.lastDrawn() == null, "not drawn into yet");

        buffer.markDrawn(5);
        Approx.check(buffer.lastDrawn() != null, "drawn into");

        buffer.bitmap();
        Approx.check(buffer.isCurrent(5), "the kept bitmap stays current");

        buffer.prepare();
        Approx.check(buffer.lastDrawn() == null, "gone after a new layout");
        Approx.check(!buffer.isCurrent(5), "not current after a new layout");

        return true;
    }
}

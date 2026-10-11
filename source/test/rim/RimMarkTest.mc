import Toybox.Lang;
import Toybox.Test;

//! The hour hand's gap facing the noon mark, left out while it would cut
//! into the noon line. Degrees clockwise from the top.
(:test)
module RimMarkTest {

    (:test)
    function sideFacing(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var size = sizes[i];
            var circle = new DayCircle(new Daylight());
            var mark = new RimMark(circle);

            Probe.screen(size);
            circle.prepare();
            mark.prepare();

            // A mark's line is twice the circle's
            var clearance = circle.gapClearance(circle.width() * 2);
            var near = clearance * 0.9;
            var clear = clearance * 1.1;

            logger.debug(size + "px: clearance " + clearance + "°");
            Approx.checkEqual(mark.sideFacing(90.0, null), 0, size + "px no other mark");
            Approx.checkEqual(mark.sideFacing(90.0, 90.0 + near), 1, size + "px clockwise, close");
            Approx.checkEqual(mark.sideFacing(90.0, 90.0 - near), -1, size + "px counterclockwise, close");
            Approx.checkEqual(mark.sideFacing(90.0, 90.0 + clear), 0, size + "px clockwise, clear");
            Approx.checkEqual(mark.sideFacing(90.0, 90.0 - clear), 0, size + "px counterclockwise, clear");
            Approx.checkEqual(mark.sideFacing(90.0, 270.0), 0, size + "px across the dial");
            Approx.check(mark.sideFacing(90.0, 90.0) != 0, size + "px on top: a side either way");
        }

        return true;
    }

    //! Either side of the top, where the positions wrap
    (:test)
    function acrossTheTop(logger as Test.Logger) as Boolean {
        var circle = new DayCircle(new Daylight());
        var mark = new RimMark(circle);

        Probe.screen(Probe.SMALL_SCREEN);
        circle.prepare();
        mark.prepare();

        Approx.checkEqual(mark.sideFacing(359.0, 1.0), 1, "the other just clockwise of the top");
        Approx.checkEqual(mark.sideFacing(1.0, 359.0), -1, "the other just counterclockwise of the top");

        return true;
    }

    //! Drawn with the other mark at every distance without failing
    (:test)
    function draws(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var dc = bitmap.getDc();
        var circle = new DayCircle(Probe.daylight(6 * 60, 18 * 60, 50.0, 0.0));
        var mark = new RimMark(circle);
        var offsets = [-10.0, -3.0, -1.0, 0.0, 1.0, 3.0, 10.0] as Array<Float>;

        circle.prepare();
        mark.prepare();

        for (var i = 0; i < offsets.size(); i++) {
            circle.draw(dc);
            mark.draw(dc, 0.0, DayColors.DAY, null);
            mark.draw(dc, offsets[i], DayColors.FALLBACK, 0.0);
        }

        return true;
    }
}

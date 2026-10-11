import Toybox.Lang;
import Toybox.Test;

(:test)
module DayCircleTest {

    //! The line's outer edge against the glass, its weight growing with
    //! the screen
    (:test)
    function geometry(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            Probe.screen(sizes[i]);

            var circle = new DayCircle(new Daylight());

            circle.prepare();

            var reach = (circle.width() + 1) / 2;

            logger.debug(sizes[i] + "px: width " + circle.width() + ", middle " + circle.middle() + ", inner " + circle.inner());
            Approx.checkEqual(circle.width(), 2 + (Dial.rim / 54), sizes[i] + "px width");
            Approx.checkEqual(circle.middle() + reach, Dial.rim, sizes[i] + "px against the glass");
            Approx.checkEqual(circle.inner(), circle.middle() - reach, sizes[i] + "px inner edge");
        }

        return true;
    }

    //! Every kind of day drawn without failing: no sun, an ordinary day, a
    //! white night where dawn and dusk meet, and no twilight
    (:test)
    function drawsEveryDay(logger as Test.Logger) as Boolean {
        var days = [
            Probe.daylight(null, null, null, 0.0),
            Probe.daylight(6 * 60, 18 * 60, 50.0, 0.0),
            Probe.daylight(150, 1290, 65.0, Twilight.TILT),
            Probe.daylight(6 * 60, 19 * 60, 0.0, 0.0)
        ] as Array<Daylight>;
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var bitmap = Probe.screen(sizes[i]);
            var dc = bitmap.getDc();

            for (var d = 0; d < days.size(); d++) {
                var circle = new DayCircle(days[d]);

                circle.prepare();
                circle.draw(dc);
            }
        }

        return true;
    }
}

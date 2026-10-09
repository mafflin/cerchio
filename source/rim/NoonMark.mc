import Toybox.Graphics;
import Toybox.Lang;

//! Solar noon on the 24 hour dial, as a RimMark in the day's color; none
//! until the sun is known.
class NoonMark {

    private var mark as RimMark;
    private var dayColors as DayColors;

    function initialize(mark as RimMark, dayColors as DayColors) {
        self.mark = mark;
        self.dayColors = dayColors;
    }

    function draw(dc as Dc) as Void {
        var zenith = dayColors.zenith();

        if (zenith == null) {
            return;
        }

        mark.draw(dc, zenith, dayColors.dayColor());
    }
}

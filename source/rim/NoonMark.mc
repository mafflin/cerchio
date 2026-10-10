import Toybox.Graphics;
import Toybox.Lang;

//! Solar noon on the 24 hour dial, as a RimMark in the day's color; none
//! until the sun is known.
class NoonMark {

    private var mark as RimMark;
    private var daylight as Daylight;
    private var dayColors as DayColors;

    function initialize(mark as RimMark, daylight as Daylight, dayColors as DayColors) {
        self.mark = mark;
        self.daylight = daylight;
        self.dayColors = dayColors;
    }

    function draw(dc as Dc) as Void {
        var zenith = daylight.zenith();

        if (zenith == null) {
            return;
        }

        mark.draw(dc, Dial.positionOfMinute(zenith), dayColors.dayColor());
    }
}

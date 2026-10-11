import Toybox.Graphics;
import Toybox.Lang;

//! Solar noon on the 24 hour dial, as a RimMark in the day's color; none
//! until the sun is known.
class NoonMark {

    private var mark as RimMark;
    private var daylight as Daylight;

    function initialize(mark as RimMark, daylight as Daylight) {
        self.mark = mark;
        self.daylight = daylight;
    }

    function draw(dc as Dc) as Void {
        var noon = position();

        if (noon != null) {
            mark.draw(dc, noon, DayColors.DAY, null);
        }
    }

    //! On the dial, in degrees clockwise from the top; null until the sun is
    //! known
    function position() as Float? {
        var zenith = daylight.zenith();

        return (zenith != null) ? Dial.positionOfMinute(zenith) : null;
    }
}

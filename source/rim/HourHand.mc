import Toybox.Graphics;
import Toybox.Lang;

//! The hour on the 24 hour dial, as a white RimMark.
class HourHand {

    private const COLOR = Graphics.COLOR_WHITE;

    private var mark as RimMark;

    function initialize(mark as RimMark) {
        self.mark = mark;
    }

    function draw(dc as Dc) as Void {
        mark.draw(dc, Dial.positionOfMinute(Clock.minuteOfDay()), COLOR);
    }
}

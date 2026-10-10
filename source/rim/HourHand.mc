import Toybox.Graphics;
import Toybox.Lang;

//! The hour on the 24 hour dial, as a RimMark in the accent color.
class HourHand {

    private var mark as RimMark;
    private var color as Number = Graphics.COLOR_WHITE;

    function initialize(mark as RimMark) {
        self.mark = mark;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function draw(dc as Dc) as Void {
        mark.draw(dc, Dial.positionOfMinute(Clock.minuteOfDay()), color);
    }
}

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

    //! After the noon mark, at noon, null for none: no gap of the hand's cuts
    //! into its line
    function draw(dc as Dc, noon as Float?) as Void {
        mark.draw(dc, Dial.positionOfMinute(Clock.minuteOfDay()), color, noon);
    }
}

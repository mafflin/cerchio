import Toybox.Graphics;
import Toybox.Lang;

//! The hour on the 24 hour dial: a line across the circle, as wide as the
//! circle, reaching past it either side, with a tiny gap in the circle on
//! each side.
class HourHand {

    //! How far the pen ends reach past the circle's edges, as a share of the
    //! radius: half the air between the circle and the numerals. With the
    //! circle round the glass, the outer end runs off it.
    private const REACH_DIVISOR = Dial.AIR_DIVISOR * 2;

    //! The gaps either side, as a share of the radius
    private const GAP_DIVISOR = 64;

    private const COLOR = Graphics.COLOR_WHITE;

    private var width as Number = 1;
    private var gapLength as Number = 1;

    //! Where the line runs from and to, from the center; the round pen
    //! reaches half its width past each
    private var innerEnd as Number = 0;
    private var outerEnd as Number = 0;

    private var circle as DayCircle;

    function initialize(circle as DayCircle) {
        self.circle = circle;
    }

    //! After the circle is prepared
    function prepare() as Void {
        var reach = Dial.rim / REACH_DIVISOR;

        width = circle.width();
        gapLength = Dial.rim / GAP_DIVISOR;
        innerEnd = circle.middle() - reach;
        outerEnd = circle.middle() + reach;
    }

    function draw(dc as Dc) as Void {
        var time = Clock.now();
        var position = Dial.positionOfMinute((time.hour * Clock.MINUTES_PER_HOUR) + time.min);
        var radians = Dial.radiansOf(position);

        circle.drawGapsAround(dc, position, gapLength);

        dc.setPenWidth(width);
        dc.setColor(COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            Dial.pointX(radians, innerEnd),
            Dial.pointY(radians, innerEnd),
            Dial.pointX(radians, outerEnd),
            Dial.pointY(radians, outerEnd)
        );
    }
}

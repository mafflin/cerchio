import Toybox.Graphics;
import Toybox.Lang;

//! A mark on the 24 hour dial: a line across the circle, as wide as the
//! circle, reaching past it either side, with a tiny gap in the circle on
//! each side. The hour hand and the noon mark are both drawn as one.
class RimMark {

    //! The gaps either side, as a share of the radius
    private const GAP_DIVISOR = 64;

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
        // Past the circle's edges by half the air it keeps from its
        // neighbors; against the glass, the glass cuts off the outer end.
        var reach = Dial.air / 2;

        width = circle.width();
        gapLength = Dial.rim / GAP_DIVISOR;
        innerEnd = circle.middle() - reach;
        outerEnd = circle.middle() + reach;
    }

    //! At a dial position, in degrees clockwise from the top
    function draw(dc as Dc, position as Float, color as Number) as Void {
        var radians = Dial.radiansOf(position);

        circle.drawGapsAround(dc, position, gapLength);

        dc.setPenWidth(width);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            Dial.pointX(radians, innerEnd),
            Dial.pointY(radians, innerEnd),
            Dial.pointX(radians, outerEnd),
            Dial.pointY(radians, outerEnd)
        );
    }
}

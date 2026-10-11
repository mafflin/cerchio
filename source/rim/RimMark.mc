import Toybox.Graphics;
import Toybox.Lang;

//! A mark on the 24 hour dial: a line across the circle, twice as wide as
//! the circle, reaching past it either side, with a gap in the circle on
//! each side as wide as those at the color changes. The hour hand and the
//! noon mark are both drawn as one.
class RimMark {

    //! The line's width, as a multiple of the circle's
    private const WIDTH_FACTOR = 2;

    private var width as Number = 1;

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
        // neighbors; the glass cuts off the outer end.
        var reach = Dial.air / 2;

        width = circle.width() * WIDTH_FACTOR;
        innerEnd = circle.middle() - reach;
        outerEnd = circle.middle() + reach;
    }

    //! At a dial position, in degrees clockwise from the top. The gap facing
    //! a mark drawn before at clearOf is left out where it would cut into that
    //! mark's line, which then sits in that mark's own gap; null for none.
    function draw(dc as Dc, position as Float, color as Number, clearOf as Float?) as Void {
        var radians = Dial.radiansOf(position);
        var facing = sideFacing(position, clearOf);

        if (facing != 1) {
            circle.drawGapBeside(dc, position, width, 1);
        }

        if (facing != -1) {
            circle.drawGapBeside(dc, position, width, -1);
        }

        dc.setPenWidth(width);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            Dial.pointX(radians, innerEnd),
            Dial.pointY(radians, innerEnd),
            Dial.pointX(radians, outerEnd),
            Dial.pointY(radians, outerEnd)
        );
    }

    //! The side the other mark is on, 1 clockwise and -1 counterclockwise,
    //! where the gap on that side would cut into its line; 0 further apart,
    //! or with no other mark
    function sideFacing(position as Float, other as Float?) as Number {
        if (other == null) {
            return 0;
        }

        var apart = other - position;

        if (apart > Dial.HALF_TURN) {
            apart -= Dial.DEGREES_PER_CIRCLE;
        } else if (apart < -Dial.HALF_TURN) {
            apart += Dial.DEGREES_PER_CIRCLE;
        }

        if (apart.abs() > circle.gapClearance(width)) {
            return 0;
        }

        return (apart > 0) ? 1 : -1;
    }
}

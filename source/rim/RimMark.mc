import Toybox.Graphics;
import Toybox.Lang;

//! A mark on the 24 hour dial: a line across the circle, twice as wide as
//! the circle, reaching past it either side, over a fatter one in the
//! background color that sets it apart from the circle and any mark under
//! it. The hour hand and the noon mark are both drawn as one.
class RimMark {

    //! The line's width, as a multiple of the circle's
    private const WIDTH_FACTOR = 2;

    //! The outline's width, as a multiple of the circle's: half the circle's
    //! width past the line on either side
    private const OUTLINE_FACTOR = 3;

    private var width as Number = 1;
    private var outlineWidth as Number = 1;

    //! Where the line runs from and to, from the center; the round pen
    //! reaches half its width past each
    private var innerEnd as Number = 0;
    private var outerEnd as Number = 0;

    function initialize() {
    }

    //! After Dial.setup(): the circle's line width, and its middle from the
    //! center
    function prepare(circleWidth as Number, circleMiddle as Number) as Void {
        width = circleWidth * WIDTH_FACTOR;
        outlineWidth = circleWidth * OUTLINE_FACTOR;

        // Inside, past the circle's edge by half the air it keeps from its
        // neighbors. Outside, well past the glass, which cuts it off: a long
        // line keeps its direction where the ends are rounded to whole pixels.
        innerEnd = circleMiddle - (Dial.air / 2);
        outerEnd = Dial.rim * 2;
    }

    //! At a dial position, in degrees clockwise from the top
    function draw(dc as Dc, position as Float, color as Number) as Void {
        var radians = Dial.radiansOf(position);

        drawLine(dc, radians, outlineWidth, Palette.BACKGROUND);
        drawLine(dc, radians, width, color);
    }

    private function drawLine(dc as Dc, radians as Decimal, penWidth as Number, color as Number) as Void {
        dc.setPenWidth(penWidth);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            Dial.pointX(radians, innerEnd),
            Dial.pointY(radians, innerEnd),
            Dial.pointX(radians, outerEnd),
            Dial.pointY(radians, outerEnd)
        );
    }
}

import Toybox.Graphics;
import Toybox.Lang;

//! A line across the circle over a background outline. The hour hand and
//! the noon mark.
class RimMark {

    //! Multiples of the circle's width
    private const WIDTH_FACTOR = 2;
    private const OUTLINE_FACTOR = 3;

    private var width as Number = 1;
    private var outlineWidth as Number = 1;

    private var innerEnd as Number = 0;
    private var outerEnd as Number = 0;

    function initialize() {
    }

    function prepare(circleWidth as Number, circleMiddle as Number) as Void {
        width = circleWidth * WIDTH_FACTOR;
        outlineWidth = circleWidth * OUTLINE_FACTOR;

        // Far past the glass: a long line keeps its angle despite pixel
        // rounding
        innerEnd = circleMiddle - (Dial.air / 2);
        outerEnd = Dial.rim * 2;
    }

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

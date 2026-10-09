import Toybox.Graphics;
import Toybox.Lang;

//! The seconds hand: a short bar with round ends pointing out, its outer end
//! on the glass, or just inside a circle against it.
class SecondsHand extends SecondsMarker {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! The bar's width and its length, end to end, as shares of the radius:
    //! 11px by 18px on a 260px screen
    private const WIDTH_DIVISOR = 11;
    private const LENGTH_DIVISOR = 7;

    //! Past the ends on every side, for the smoothed edges
    private const PADDING = 1;

    private var penWidth as Number = 1;

    //! Per second: the two ends' centers, outer x and y then inner x and y,
    //! and the box the bar fits in, left, top, right and bottom
    private var ends as Array<Array<Number> >;
    private var boxes as Array<Array<Number> >;

    function initialize() {
        SecondsMarker.initialize();
        ends = new [COUNT] as Array<Array<Number> >;
        boxes = new [COUNT] as Array<Array<Number> >;
    }

    //! After Dial.setup(). Null for no circle against the glass: the outer
    //! end is on the glass.
    function prepare(circleInnerEdge as Number?) as Void {
        var tipRadius = (circleInnerEdge != null) ? (circleInnerEdge - Dial.air) : Dial.rim;

        penWidth = Dial.rim / WIDTH_DIVISOR;

        // The round pen reaches half its width past each end's center.
        var reach = penWidth / 2;
        var outerRadius = tipRadius - reach;
        var innerRadius = tipRadius - (Dial.rim / LENGTH_DIVISOR) + reach;

        for (var second = 0; second < COUNT; second++) {
            place(second, outerRadius, innerRadius, reach);
        }

        forget();
    }

    protected function paintAt(dc as Dc, second as Number) as Void {
        var bar = ends[second];

        dc.setPenWidth(penWidth);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(bar[0], bar[1], bar[2], bar[3]);
    }

    protected function boxOf(second as Number) as Array<Number> {
        return boxes[second];
    }

    private function place(second as Number, outerRadius as Number, innerRadius as Number, reach as Number) as Void {
        var radians = Dial.radiansOf(second * Dial.DEGREES_PER_SECOND);
        var bar = [
            Dial.pointX(radians, outerRadius),
            Dial.pointY(radians, outerRadius),
            Dial.pointX(radians, innerRadius),
            Dial.pointY(radians, innerRadius)
        ];

        ends[second] = bar;
        boxes[second] = boxAround(bar, reach + PADDING);
    }

    //! The ends grown by the pen's reach, cut down to the screen
    private function boxAround(bar as Array<Number>, margin as Number) as Array<Number> {
        return [
            Numbers.max(Numbers.min(bar[0], bar[2]) - margin, 0),
            Numbers.max(Numbers.min(bar[1], bar[3]) - margin, 0),
            Numbers.min(Numbers.max(bar[0], bar[2]) + margin + 1, Dial.screenWidth),
            Numbers.min(Numbers.max(bar[1], bar[3]) + margin + 1, Dial.screenHeight)
        ];
    }
}

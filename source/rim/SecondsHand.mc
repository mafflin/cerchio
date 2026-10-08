import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! The seconds hand: an equilateral arrow pointing out, its tip on the
//! glass, or just inside a circle against it.
class SecondsHand extends SecondsMarker {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! The base, in degrees at the tip: wider inside a circle, where the tip
    //! sits nearer the middle
    private const WIDTH_DEGREES = 6;
    private const INSIDE_WIDTH_DEGREES = 8;

    //! An equilateral triangle's height over its base
    private const EQUILATERAL_HEIGHT = 0.866;

    //! Past the corners on every side, for the smoothed edges
    private const PADDING = 1;

    //! Per second: the tip, the two base corners, and the box they fit in,
    //! left, top, right and bottom
    private var corners as Array<Array<[Numeric, Numeric]> >;
    private var boxes as Array<Array<Number> >;

    function initialize() {
        SecondsMarker.initialize();
        corners = new [COUNT] as Array<Array<[Numeric, Numeric]> >;
        boxes = new [COUNT] as Array<Array<Number> >;
    }

    //! After Dial.setup(). Null for no circle against the glass: the tip is
    //! on the glass.
    function prepare(circleInnerEdge as Number?) as Void {
        var tipRadius = Dial.rim;
        var widthDegrees = WIDTH_DEGREES;

        if (circleInnerEdge != null) {
            tipRadius = circleInnerEdge - Dial.air;
            widthDegrees = INSIDE_WIDTH_DEGREES;
        }

        var baseWidth = (2 * tipRadius * Math.sin(Math.toRadians(widthDegrees / 2.0))).toFloat();
        var baseRadius = (tipRadius - (baseWidth * EQUILATERAL_HEIGHT)).toFloat();

        for (var second = 0; second < COUNT; second++) {
            place(second, tipRadius, baseRadius, baseWidth / 2);
        }

        forget();
    }

    protected function paintAt(dc as Dc, second as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(corners[second]);
    }

    protected function boxOf(second as Number) as Array<Number> {
        return boxes[second];
    }

    private function place(second as Number, tipRadius as Number, baseRadius as Float, halfWidth as Float) as Void {
        var radians = Dial.radiansOf(second * Dial.DEGREES_PER_SECOND);
        var outX = Math.cos(radians);

        // Screen y grows downward.
        var outY = -Math.sin(radians);

        // Across is out turned a quarter.
        var acrossX = -outY * halfWidth;
        var acrossY = outX * halfWidth;
        var baseX = Dial.centerX + (baseRadius * outX);
        var baseY = Dial.centerY + (baseRadius * outY);

        corners[second] = [
            [Dial.pointX(radians, tipRadius), Dial.pointY(radians, tipRadius)],
            [Dial.pixel(baseX + acrossX), Dial.pixel(baseY + acrossY)],
            [Dial.pixel(baseX - acrossX), Dial.pixel(baseY - acrossY)]
        ] as Array<[Numeric, Numeric]>;

        boxes[second] = boxAround(corners[second]);
    }

    //! Round the corners by the padding, cut down to the screen
    private function boxAround(points as Array<[Numeric, Numeric]>) as Array<Number> {
        var left = points[0][0].toNumber();
        var top = points[0][1].toNumber();
        var right = left;
        var bottom = top;

        for (var i = 1; i < points.size(); i++) {
            left = Numbers.min(left, points[i][0].toNumber());
            top = Numbers.min(top, points[i][1].toNumber());
            right = Numbers.max(right, points[i][0].toNumber());
            bottom = Numbers.max(bottom, points[i][1].toNumber());
        }

        return [
            Numbers.max(left - PADDING, 0),
            Numbers.max(top - PADDING, 0),
            Numbers.min(right + PADDING + 1, Dial.screenWidth),
            Numbers.min(bottom + PADDING + 1, Dial.screenHeight)
        ];
    }
}

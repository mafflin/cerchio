import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! The seconds hand: an equilateral arrow pointing out, its tip on the
//! glass, or just inside a circle against it. Every position is worked out once per screen, so a tick only
//! looks up three corners and their box. In low power mode a partial update
//! copies the face back over the old box and the new one, then draws.
class SecondsHand {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! The base, in degrees at the tip: wider inside a circle, where the tip
    //! sits nearer the middle
    private const WIDTH_DEGREES = 6;
    private const INSIDE_WIDTH_DEGREES = 8;

    //! An equilateral triangle's height over its base
    private const EQUILATERAL_HEIGHT = 0.866;

    //! Past the corners on every side, for the smoothed edges
    private const PADDING = 1;

    private var color as Number = Graphics.COLOR_WHITE;

    //! Per second: the tip, the two base corners, and the box they fit in
    private var corners as Array<Array<[Numeric, Numeric]> >;
    private var lefts as Array<Number>;
    private var tops as Array<Number>;
    private var rights as Array<Number>;
    private var bottoms as Array<Number>;

    //! Where it was last drawn, null when off screen
    private var drawnSecond as Number? = null;

    function initialize() {
        corners = new [COUNT] as Array<Array<[Numeric, Numeric]> >;
        lefts = new [COUNT] as Array<Number>;
        tops = new [COUNT] as Array<Number>;
        rights = new [COUNT] as Array<Number>;
        bottoms = new [COUNT] as Array<Number>;
    }

    function setColor(color as Number) as Void {
        self.color = color;
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

        drawnSecond = null;
    }

    //! So the next tick does not lift it off a screen since repainted
    function forget() as Void {
        drawnSecond = null;
    }

    function draw(dc as Dc) as Void {
        paint(dc, Clock.now().sec);
    }

    //! Copy the face back over where it was and where it goes, then draw
    function drawPartial(dc as Dc, face as BufferedBitmap) as Void {
        var second = Clock.now().sec;
        var previous = drawnSecond;

        if (second == previous) {
            return;
        }

        if (previous == null) {
            previous = second;
        }

        clipAround(dc, previous, second);
        dc.drawBitmap(0, 0, face);
        paint(dc, second);
        dc.clearClip();
    }

    private function paint(dc as Dc, second as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(corners[second]);

        drawnSecond = second;
    }

    //! The box around both seconds' arrows
    private function clipAround(dc as Dc, first as Number, second as Number) as Void {
        var left = Numbers.min(lefts[first], lefts[second]);
        var top = Numbers.min(tops[first], tops[second]);
        var right = Numbers.max(rights[first], rights[second]);
        var bottom = Numbers.max(bottoms[first], bottoms[second]);

        dc.setClip(left, top, right - left, bottom - top);
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

        boxAround(second);
    }

    //! Round the corners by the padding, cut down to the screen
    private function boxAround(second as Number) as Void {
        var points = corners[second];
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

        lefts[second] = Numbers.max(left - PADDING, 0);
        tops[second] = Numbers.max(top - PADDING, 0);
        rights[second] = Numbers.min(right + PADDING + 1, Dial.screenWidth);
        bottoms[second] = Numbers.min(bottom + PADDING + 1, Dial.screenHeight);
    }
}

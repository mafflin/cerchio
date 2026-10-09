import Toybox.Graphics;
import Toybox.Lang;

//! The seconds hand over the off screen face: a short bar with round ends,
//! pointing out, just inside the circle or just outside it toward the glass.
//! Every second's place and box is worked out once per screen, so a tick
//! only looks them up. In low power mode a partial update copies the face
//! back over the old box and the new one, then draws.
class SecondsHand {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! The bar's width and its length, end to end, as shares of the radius:
    //! 11px by 18px on a 260px screen
    private const WIDTH_DIVISOR = 11;
    private const LENGTH_DIVISOR = 7;

    //! Past the ends on every side, for the smoothed edges
    private const PADDING = 1;

    private var color as Number = Graphics.COLOR_WHITE;
    private var penWidth as Number = 1;

    //! Per second: the two ends' centers, outer x and y then inner x and y,
    //! and the box the bar fits in, left, top, right and bottom
    private var ends as Array<Array<Number> >;
    private var boxes as Array<Array<Number> >;

    //! Where it was last drawn, null when off screen
    private var drawnSecond as Number? = null;

    function initialize() {
        ends = new [COUNT] as Array<Array<Number> >;
        boxes = new [COUNT] as Array<Array<Number> >;
    }

    //! After Dial.setup(): the outer end the air inside the circle
    function placeInside(circleInnerEdge as Number) as Void {
        var outer = circleInnerEdge - Dial.air;

        placeBetween(outer - length(), outer);
    }

    //! After Dial.setup(): the inner end the air outside the circle, the bar
    //! reaching out toward the glass
    function placeOutside(circleOuterEdge as Number) as Void {
        var inner = circleOuterEdge + Dial.air;

        placeBetween(inner, inner + length());
    }

    function setColor(color as Number) as Void {
        self.color = color;
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

    private function length() as Number {
        return Dial.rim / LENGTH_DIVISOR;
    }

    //! The bar's ink from one radius to the other, every second
    private function placeBetween(innerEdge as Number, outerEdge as Number) as Void {
        penWidth = Dial.rim / WIDTH_DIVISOR;

        // The round pen reaches half its width past each end's center.
        var reach = penWidth / 2;

        for (var second = 0; second < COUNT; second++) {
            place(second, outerEdge - reach, innerEdge + reach, reach);
        }

        forget();
    }

    private function paint(dc as Dc, second as Number) as Void {
        var bar = ends[second];

        dc.setPenWidth(penWidth);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(bar[0], bar[1], bar[2], bar[3]);
        drawnSecond = second;
    }

    //! The box around both seconds
    private function clipAround(dc as Dc, first as Number, second as Number) as Void {
        var a = boxes[first];
        var b = boxes[second];
        var left = Numbers.min(a[0], b[0]);
        var top = Numbers.min(a[1], b[1]);
        var right = Numbers.max(a[2], b[2]);
        var bottom = Numbers.max(a[3], b[3]);

        dc.setClip(left, top, right - left, bottom - top);
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

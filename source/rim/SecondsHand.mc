import Toybox.Graphics;
import Toybox.Lang;

//! A dot: looks the same at every angle, unlike a bar. Positions are
//! precomputed per screen.
class SecondsHand {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! 6px on a 260px screen
    private const RADIUS_DIVISOR = 21;

    //! For anti-aliased edges
    private const PADDING = 1;

    private var color as Number = Graphics.COLOR_WHITE;
    private var dotRadius as Number = 1;

    //! Per second: [x, y] and [left, top, right, bottom]
    private var centers as Array<Array<Number> >;
    private var boxes as Array<Array<Number> >;

    //! Null when not on screen
    private var drawnSecond as Number? = null;

    function initialize() {
        centers = new [COUNT] as Array<Array<Number> >;
        boxes = new [COUNT] as Array<Array<Number> >;
    }

    function place(circleInnerEdge as Number) as Void {
        dotRadius = Dial.rim / RADIUS_DIVISOR;
        placeAt(circleInnerEdge - Dial.air - dotRadius);
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! After a full repaint
    function forget() as Void {
        drawnSecond = null;
    }

    function centerOf(second as Number) as Array<Number> {
        return centers[second];
    }

    function boxOf(second as Number) as Array<Number> {
        return boxes[second];
    }

    function draw(dc as Dc) as Void {
        paint(dc, Clock.now().sec);
    }

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

    private function placeAt(radius as Number) as Void {
        for (var second = 0; second < COUNT; second++) {
            var radians = Dial.radiansOf(second * Dial.DEGREES_PER_SECOND);
            var x = Dial.pointX(radians, radius);
            var y = Dial.pointY(radians, radius);

            centers[second] = [x, y];
            boxes[second] = boxAround(x, y, dotRadius + PADDING);
        }

        forget();
    }

    private function paint(dc as Dc, second as Number) as Void {
        var center = centers[second];

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(center[0], center[1], dotRadius);
        drawnSecond = second;
    }

    private function clipAround(dc as Dc, first as Number, second as Number) as Void {
        var a = boxes[first];
        var b = boxes[second];
        var left = Numbers.min(a[0], b[0]);
        var top = Numbers.min(a[1], b[1]);
        var right = Numbers.max(a[2], b[2]);
        var bottom = Numbers.max(a[3], b[3]);

        dc.setClip(left, top, right - left, bottom - top);
    }

    private function boxAround(x as Number, y as Number, margin as Number) as Array<Number> {
        return [
            Numbers.max(x - margin, 0),
            Numbers.max(y - margin, 0),
            Numbers.min(x + margin + 1, Dial.screenWidth),
            Numbers.min(y + margin + 1, Dial.screenHeight)
        ];
    }
}

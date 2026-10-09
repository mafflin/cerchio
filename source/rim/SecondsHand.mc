import Toybox.Graphics;
import Toybox.Lang;

//! The seconds over the off screen face: a dot, just inside the circle or
//! just outside it toward the glass. Round, so it looks the same at every
//! second; a bar turned on the pixel grid shows a different shape at each.
//! Every second's place and box is worked out once per screen, so a tick
//! only looks them up. In low power mode a partial update copies the face
//! back over the old box and the new one, then draws.
class SecondsHand {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! The dot's radius, as a share of the glass's: 6px on a 260px screen,
    //! small enough to fit between the circle and the glass, and kept on
    //! either side of it
    private const RADIUS_DIVISOR = 21;

    //! Past the dot on every side, for the smoothed edges
    private const PADDING = 1;

    private var color as Number = Graphics.COLOR_WHITE;
    private var dotRadius as Number = 1;

    //! Per second: the dot's center, x and y, and the box it fits in, left,
    //! top, right and bottom
    private var centers as Array<Array<Number> >;
    private var boxes as Array<Array<Number> >;

    //! Where it was last drawn, null when off screen
    private var drawnSecond as Number? = null;

    function initialize() {
        centers = new [COUNT] as Array<Array<Number> >;
        boxes = new [COUNT] as Array<Array<Number> >;
    }

    //! After Dial.setup(): the dot's outer edge the air inside the circle
    function placeInside(circleInnerEdge as Number) as Void {
        dotRadius = Dial.rim / RADIUS_DIVISOR;
        placeAt(circleInnerEdge - Dial.air - dotRadius);
    }

    //! After Dial.setup(): the dot's inner edge the air outside the circle
    function placeOutside(circleOuterEdge as Number) as Void {
        dotRadius = Dial.rim / RADIUS_DIVISOR;
        placeAt(circleOuterEdge + Dial.air + dotRadius);
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

    //! Every second's center on one radius
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

    //! The center grown by margin, cut down to the screen
    private function boxAround(x as Number, y as Number, margin as Number) as Array<Number> {
        return [
            Numbers.max(x - margin, 0),
            Numbers.max(y - margin, 0),
            Numbers.min(x + margin + 1, Dial.screenWidth),
            Numbers.min(y + margin + 1, Dial.screenHeight)
        ];
    }
}

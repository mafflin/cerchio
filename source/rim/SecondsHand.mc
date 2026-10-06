import Toybox.Graphics;
import Toybox.Lang;

//! The seconds hand: a line from the glass in to the numerals' inner edge,
//! clear of the circle. Every position is worked out once per screen, so a
//! tick only looks up a line and its box. In low power mode a partial update
//! copies the face back over the old box and the new one, then draws.
class SecondsHand {

    private const COUNT = Dial.SECONDS_PER_TURN;

    //! Half as wide again as the hour hand
    private const WIDTH_NUMERATOR = 3;
    private const WIDTH_DIVISOR = 2;

    //! Past the pen on every side, for its smoothed edges
    private const PADDING = 1;

    private var color as Number = Graphics.COLOR_WHITE;
    private var width as Number = 1;

    //! Per second: the line's ends, and the box it fits in
    private var innerXs as Array<Number>;
    private var innerYs as Array<Number>;
    private var outerXs as Array<Number>;
    private var outerYs as Array<Number>;
    private var lefts as Array<Number>;
    private var tops as Array<Number>;
    private var rights as Array<Number>;
    private var bottoms as Array<Number>;

    //! Where it was last drawn, null when off screen
    private var drawnSecond as Number? = null;

    function initialize() {
        innerXs = new [COUNT] as Array<Number>;
        innerYs = new [COUNT] as Array<Number>;
        outerXs = new [COUNT] as Array<Number>;
        outerYs = new [COUNT] as Array<Number>;
        lefts = new [COUNT] as Array<Number>;
        tops = new [COUNT] as Array<Number>;
        rights = new [COUNT] as Array<Number>;
        bottoms = new [COUNT] as Array<Number>;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! The round pen ends at innerEdge; outside, it runs off the glass
    function prepare(hourHandWidth as Number, innerEdge as Number) as Void {
        width = hourHandWidth * WIDTH_NUMERATOR / WIDTH_DIVISOR;

        var inner = innerEdge + ((width + 1) / 2);

        for (var second = 0; second < COUNT; second++) {
            place(second, inner);
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
        dc.setPenWidth(width);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(innerXs[second], innerYs[second], outerXs[second], outerYs[second]);

        drawnSecond = second;
    }

    //! The box around both seconds' lines
    private function clipAround(dc as Dc, first as Number, second as Number) as Void {
        var left = Numbers.min(lefts[first], lefts[second]);
        var top = Numbers.min(tops[first], tops[second]);
        var right = Numbers.max(rights[first], rights[second]);
        var bottom = Numbers.max(bottoms[first], bottoms[second]);

        dc.setClip(left, top, right - left, bottom - top);
    }

    private function place(second as Number, inner as Number) as Void {
        var radians = Dial.radiansOf(second * Dial.DEGREES_PER_SECOND);

        innerXs[second] = Dial.pointX(radians, inner);
        innerYs[second] = Dial.pointY(radians, inner);
        outerXs[second] = Dial.pointX(radians, Dial.rim);
        outerYs[second] = Dial.pointY(radians, Dial.rim);

        boxAround(second);
    }

    //! Past the ends by the round pen and the padding, cut down to the screen
    private function boxAround(second as Number) as Void {
        var reach = ((width + 1) / 2) + PADDING;

        lefts[second] = Numbers.max(Numbers.min(innerXs[second], outerXs[second]) - reach, 0);
        tops[second] = Numbers.max(Numbers.min(innerYs[second], outerYs[second]) - reach, 0);
        rights[second] = Numbers.min(Numbers.max(innerXs[second], outerXs[second]) + reach + 1, Dial.screenWidth);
        bottoms[second] = Numbers.min(Numbers.max(innerYs[second], outerYs[second]) + reach + 1, Dial.screenHeight);
    }
}

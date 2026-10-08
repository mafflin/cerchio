import Toybox.Graphics;
import Toybox.Lang;

//! What shows the seconds over the off screen face: the seconds hand, or the
//! numeral nearest the second. Each works out every position and its box
//! once per screen, so a tick only looks them up. In low power mode a
//! partial update copies the face back over the old box and the new one,
//! then draws. A subclass says where a second lands, how that is drawn, and
//! the box it is drawn in.
class SecondsMarker {

    protected var color as Number = Graphics.COLOR_WHITE;

    //! Where it was last drawn, null when off screen
    private var drawnPosition as Number? = null;

    function initialize() {
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! So the next tick does not lift it off a screen since repainted
    function forget() as Void {
        drawnPosition = null;
    }

    function draw(dc as Dc) as Void {
        paint(dc, positionAt(Clock.now().sec));
    }

    //! Copy the face back over where it was and where it goes, then draw
    function drawPartial(dc as Dc, face as BufferedBitmap) as Void {
        var position = positionAt(Clock.now().sec);
        var previous = drawnPosition;

        if (position == previous) {
            return;
        }

        if (previous == null) {
            previous = position;
        }

        clipAround(dc, previous, position);
        dc.drawBitmap(0, 0, face);
        paint(dc, position);
        dc.clearClip();
    }

    //! Overridden where a position is not the second itself
    protected function positionAt(second as Number) as Number {
        return second;
    }

    //! Overridden: draw at a position in color
    protected function paintAt(dc as Dc, position as Number) as Void {
    }

    //! Overridden: left, top, right and bottom of where paintAt() reaches
    protected function boxOf(position as Number) as Array<Number> {
        return [0, 0, 0, 0];
    }

    private function paint(dc as Dc, position as Number) as Void {
        paintAt(dc, position);
        drawnPosition = position;
    }

    //! The box around both positions
    private function clipAround(dc as Dc, first as Number, second as Number) as Void {
        var a = boxOf(first);
        var b = boxOf(second);
        var left = Numbers.min(a[0], b[0]);
        var top = Numbers.min(a[1], b[1]);
        var right = Numbers.max(a[2], b[2]);
        var bottom = Numbers.max(a[3], b[3]);

        dc.setClip(left, top, right - left, bottom - top);
    }
}

import Toybox.Graphics;
import Toybox.Lang;

//! Progress to the goal: a dot just inside the circle against the glass,
//! gliding round from the top a degree at a time as the goal is done. Not
//! started and done are both at the top. A ring until the goal is done,
//! solid once it is.
class GoalDot {

    //! The dot's radius against the circle's line width, so it keeps to the
    //! line's weight on every screen
    private const SIZE_RATIO = 1.25;

    //! The ring's width, as a share of the dot's radius, at least MIN_RING
    private const RING_DIVISOR = 2;
    private const MIN_RING = 2;

    private var color as Number = Graphics.COLOR_WHITE;
    private var dotRadius as Number = 1;
    private var ringWidth as Number = 1;

    //! The dot's center, from the center
    private var radius as Number = 0;

    //! Whole degrees clockwise from the top, null for none
    private var degrees as Number? = null;
    private var isDone as Boolean = false;

    function initialize() {
    }

    //! After Dial.setup(): the air inside the circle the seconds dot keeps
    function prepare(circleWidth as Number, circleInnerEdge as Number) as Void {
        dotRadius = Numbers.round(circleWidth * SIZE_RATIO);
        ringWidth = Numbers.max(dotRadius / RING_DIVISOR, MIN_RING);

        radius = circleInnerEdge - Dial.air - dotRadius;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! 0 to 1; null without a goal, which shows nothing
    function setShare(share as Float?) as Void {
        if (share == null) {
            degrees = null;
            return;
        }

        degrees = Numbers.round(share * Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
        isDone = (share >= 1.0);
    }

    function draw(dc as Dc) as Void {
        var position = degrees;

        if (position == null) {
            return;
        }

        var radians = Dial.radiansOf(position);
        var x = Dial.pointX(radians, radius);
        var y = Dial.pointY(radians, radius);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (isDone) {
            dc.fillCircle(x, y, dotRadius);
            return;
        }

        // The pen reaches half its width either side of the radius.
        dc.setPenWidth(ringWidth);
        dc.drawCircle(x, y, dotRadius - (ringWidth / 2));
    }
}

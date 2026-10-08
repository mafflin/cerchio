import Toybox.Graphics;
import Toybox.Lang;

//! Progress to the goal: a dot centered on the glass, so only its inner half
//! shows, or whole just inside a circle against the glass, gliding round from
//! the top a degree at a time as the goal is done. Done is back at the top.
class GoalDot {

    //! The air between the dot and a circle against the glass, in Dial.air:
    //! twice what the seconds hand keeps, so the dot sits further in
    private const AIR_INSIDE = 2;

    private var color as Number = Graphics.COLOR_WHITE;
    private var dotRadius as Number = 1;

    //! The dot's center, from the center
    private var radius as Number = 0;

    //! Whole degrees clockwise from the top, null for none
    private var degrees as Number? = null;

    function initialize() {
    }

    //! After Dial.setup(). Null for no circle against the glass: the dot is
    //! centered on the glass.
    function prepare(dotRadius as Number, circleInnerEdge as Number?) as Void {
        self.dotRadius = dotRadius;

        radius = (circleInnerEdge == null) ? Dial.rim : (circleInnerEdge - (AIR_INSIDE * Dial.air) - dotRadius);
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! 0 to 1; nothing until the goal is started
    function setShare(share as Float?) as Void {
        if ((share == null) || (share <= 0)) {
            degrees = null;
            return;
        }

        degrees = Dial.pixel(share * Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
    }

    function draw(dc as Dc) as Void {
        var position = degrees;

        if (position == null) {
            return;
        }

        var radians = Dial.radiansOf(position);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Dial.pointX(radians, radius), Dial.pointY(radians, radius), dotRadius);
    }
}

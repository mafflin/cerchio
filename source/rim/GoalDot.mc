import Toybox.Graphics;
import Toybox.Lang;

//! Progress to the goal: a dot on the numerals' line, gliding round from the
//! top a degree at a time as the goal is done, over any numeral in its way.
class GoalDot {

    private var color as Number = Graphics.COLOR_WHITE;

    //! Midway across the numerals, from the center
    private var radius as Float = 0.0;
    private var dotRadius as Number = 1;

    //! Whole degrees clockwise from the top, null for none
    private var degrees as Number? = null;

    function initialize() {
    }

    //! After the numerals are prepared
    function prepare(radius as Float, dotRadius as Number) as Void {
        self.radius = radius;
        self.dotRadius = dotRadius;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! 0 to 1; nothing until the goal is started. Done is back at the top.
    function setShare(share as Float?) as Void {
        if ((share == null) || (share <= 0)) {
            degrees = null;
            return;
        }

        degrees = Dial.pixel(share * Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
    }

    function draw(dc as Dc) as Void {
        if (degrees == null) {
            return;
        }

        var radians = Dial.radiansOf(degrees);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(Dial.pointX(radians, radius), Dial.pointY(radians, radius), dotRadius);
    }
}

import Toybox.Graphics;
import Toybox.Lang;

//! Goal progress as a ring on the rim; a ring so it isn't mistaken for the
//! seconds dot
class GoalDot {

    //! Against the circle's width
    private const SIZE_RATIO = 1.25;

    //! Against the dot's radius
    private const RING_DIVISOR = 2;
    private const MIN_RING = 2;

    private var color as Number = Graphics.COLOR_WHITE;
    private var dotRadius as Number = 1;
    private var ringWidth as Number = 1;

    private var radius as Number = 0;

    //! Null for no goal
    private var degrees as Number? = null;
    private var share as Float = 0.0;

    private var progress as GoalProgress;

    function initialize() {
        progress = new GoalProgress();
    }

    function prepare(circleWidth as Number, circleInnerEdge as Number) as Void {
        dotRadius = Numbers.round(circleWidth * SIZE_RATIO);
        ringWidth = Numbers.max(dotRadius / RING_DIVISOR, MIN_RING);

        radius = circleInnerEdge - Dial.air - dotRadius;
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function refresh() as Void {
        progress.refresh();
        setShare(progress.share());
    }

    private function setShare(share as Float?) as Void {
        if (share == null) {
            degrees = null;
            return;
        }

        degrees = degreesOf(share);
        self.share = share;
    }

    //! Done wraps back to the top
    function degreesOf(share as Float) as Number {
        return Numbers.round(share * Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
    }

    function colorOf(share as Float) as Number {
        return (share >= 1.0) ? DayColors.TWILIGHT : color;
    }

    function draw(dc as Dc) as Void {
        var position = degrees;

        if (position == null) {
            return;
        }

        var radians = Dial.radiansOf(position);
        var x = Dial.pointX(radians, radius);
        var y = Dial.pointY(radians, radius);

        dc.setColor(colorOf(share), Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(ringWidth);
        dc.drawCircle(x, y, dotRadius - (ringWidth / 2));
    }
}

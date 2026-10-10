import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! The circle of the glass, and where a value on the dial lands on it.
module Dial {

    const DEGREES_PER_CIRCLE = 360;
    const HALF_TURN = DEGREES_PER_CIRCLE / 2;

    //! Dial zero is at the top; screen zero is at three o'clock, counterclockwise
    const TOP_DEGREES = 90;

    //! Seconds run round the glass once a minute, from the top
    const SECONDS_PER_TURN = 60;
    const DEGREES_PER_SECOND = DEGREES_PER_CIRCLE / SECONDS_PER_TURN;

    //! Midnight at the bottom, noon at the top
    const MIDNIGHT_DEGREES = HALF_TURN;

    var screenWidth as Number = 0;
    var screenHeight as Number = 0;
    var centerX as Number = 0;
    var centerY as Number = 0;
    var rim as Number = 0;

    //! The air things on the rim keep from each other, as a share of the
    //! radius
    const AIR_DIVISOR = 32;
    var air as Number = 0;

    //! Before anything sizes itself off the glass
    function setup(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        rim = Numbers.min(centerX, centerY);
        air = rim / AIR_DIVISOR;
    }

    //! Degrees clockwise from the top. A float: a minute is a quarter degree.
    function positionOfMinute(minutes as Number) as Float {
        var degrees = MIDNIGHT_DEGREES + (minutes.toFloat() * DEGREES_PER_CIRCLE / Clock.MINUTES_PER_DAY);

        return (degrees >= DEGREES_PER_CIRCLE) ? (degrees - DEGREES_PER_CIRCLE) : degrees;
    }

    //! The pixel at a screen angle and radius. Screen y grows downward.
    function pointX(radians as Decimal, radius as Numeric) as Number {
        return pixel(centerX + (radius * Math.cos(radians)));
    }

    function pointY(radians as Decimal, radius as Numeric) as Number {
        return pixel(centerY - (radius * Math.sin(radians)));
    }

    //! Rounded, not truncated: truncation drags every point the same way
    function pixel(value as Decimal) as Number {
        return Math.round(value).toNumber();
    }

    //! A dial value as a screen angle in radians
    function radiansOf(valueDegrees as Numeric) as Decimal {
        return Math.toRadians(TOP_DEGREES - valueDegrees);
    }
}

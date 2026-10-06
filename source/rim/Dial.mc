import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! The circle of the glass, and where a value on the dial lands on it.
module Dial {

    const DEGREES_PER_CIRCLE = 360;
    const HALF_TURN = DEGREES_PER_CIRCLE / 2;
    const QUARTER_TURN = DEGREES_PER_CIRCLE / 4;

    //! Dial zero is at the top; screen zero is at three o'clock, counterclockwise
    const TOP_DEGREES = 90;

    //! A full circle is a day
    const HOURS = 24;
    const DEGREES_PER_HOUR = DEGREES_PER_CIRCLE / HOURS;

    //! Midnight at the bottom, noon at the top
    const MIDNIGHT_DEGREES = HALF_TURN;
    const MINUTES_PER_DAY = HOURS * Clock.MINUTES_PER_HOUR;

    var centerX as Number = 0;
    var centerY as Number = 0;
    var rim as Number = 0;

    //! Before anything sizes itself off the glass
    function setup(dc as Dc) as Void {
        centerX = dc.getWidth() / 2;
        centerY = dc.getHeight() / 2;
        rim = (centerX < centerY) ? centerX : centerY;
    }

    //! Degrees clockwise from the top
    function positionOfHour(hour as Number) as Number {
        return (MIDNIGHT_DEGREES + (hour * DEGREES_PER_HOUR)) % DEGREES_PER_CIRCLE;
    }

    //! Degrees clockwise from the top. A float: a minute is a quarter degree.
    function positionOfMinute(minutes as Number) as Float {
        var degrees = MIDNIGHT_DEGREES + (minutes.toFloat() * DEGREES_PER_CIRCLE / MINUTES_PER_DAY);

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

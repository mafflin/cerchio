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

    var rim as Number = 0;

    //! The air things on the rim keep from each other, as a share of the
    //! radius
    const AIR_DIVISOR = 32;
    var air as Number = 0;

    //! After Screen.setup(), before anything sizes itself off the rim
    function setup() as Void {
        rim = Numbers.min(Screen.centerX, Screen.centerY);
        air = rim / AIR_DIVISOR;
    }

    //! Degrees clockwise from the top. A float: a minute is a quarter degree.
    function positionOfMinute(minutes as Number) as Float {
        var degrees = MIDNIGHT_DEGREES + (minutes.toFloat() * DEGREES_PER_CIRCLE / Clock.MINUTES_PER_DAY);

        return (degrees >= DEGREES_PER_CIRCLE) ? (degrees - DEGREES_PER_CIRCLE) : degrees;
    }

    //! The pixel at a screen angle and radius. Screen y grows downward.
    function pointX(radians as Decimal, radius as Numeric) as Number {
        return Numbers.round(Screen.centerX + (radius * Math.cos(radians)));
    }

    function pointY(radians as Decimal, radius as Numeric) as Number {
        return Numbers.round(Screen.centerY - (radius * Math.sin(radians)));
    }

    //! A dial value as a screen angle in radians
    function radiansOf(valueDegrees as Numeric) as Decimal {
        return Math.toRadians(TOP_DEGREES - valueDegrees);
    }
}

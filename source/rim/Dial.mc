import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! Screen geometry and dial positions
module Dial {

    const DEGREES_PER_CIRCLE = 360;
    const HALF_TURN = DEGREES_PER_CIRCLE / 2;

    //! Screen zero is three o'clock, counterclockwise
    const TOP_DEGREES = 90;

    const SECONDS_PER_TURN = 60;
    const DEGREES_PER_SECOND = DEGREES_PER_CIRCLE / SECONDS_PER_TURN;

    //! Midnight at the bottom, noon at the top
    const MIDNIGHT_DEGREES = HALF_TURN;

    var screenWidth as Number = 0;
    var screenHeight as Number = 0;
    var centerX as Number = 0;
    var centerY as Number = 0;
    var rim as Number = 0;

    //! Spacing between things on the rim
    const AIR_DIVISOR = 32;
    var air as Number = 0;

    //! Call first
    function setup(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        rim = Numbers.min(centerX, centerY);
        air = rim / AIR_DIVISOR;
    }

    //! Degrees clockwise from the top
    function positionOfMinute(minutes as Number) as Float {
        var degrees = MIDNIGHT_DEGREES + (minutes.toFloat() * DEGREES_PER_CIRCLE / Clock.MINUTES_PER_DAY);

        return (degrees >= DEGREES_PER_CIRCLE) ? (degrees - DEGREES_PER_CIRCLE) : degrees;
    }

    function pointX(radians as Decimal, radius as Numeric) as Number {
        return Numbers.round(centerX + (radius * Math.cos(radians)));
    }

    function pointY(radians as Decimal, radius as Numeric) as Number {
        return Numbers.round(centerY - (radius * Math.sin(radians)));
    }

    //! Dial degrees to screen radians
    function radiansOf(valueDegrees as Numeric) as Decimal {
        return Math.toRadians(TOP_DEGREES - valueDegrees);
    }
}

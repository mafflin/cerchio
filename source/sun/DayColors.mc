import Toybox.Graphics;
import Toybox.Lang;

//! The rim's colors: amber from sunrise to sunset, orange in the twilight
//! either side, sky blue through the night. The fallback color until the sun
//! is known; no orange while dawn and dusk are not.
class DayColors {

    private const DAY_COLOR = Palette.AMBER;
    private const TWILIGHT_COLOR = Palette.ORANGE;
    private const NIGHT_COLOR = Palette.SKY;

    //! Until the sun is known
    private const FALLBACK_COLOR = Graphics.COLOR_WHITE;

    private var daylight as Daylight;

    //! On the dial, null when not known
    private var sunrisePosition as Float? = null;
    private var sunsetPosition as Float? = null;
    private var zenithPosition as Float? = null;
    private var dawnPosition as Float? = null;
    private var duskPosition as Float? = null;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
    }

    //! Whenever the sun has moved
    function refresh() as Void {
        sunrisePosition = positionOf(daylight.sunrise());
        sunsetPosition = positionOf(daylight.sunset());
        zenithPosition = positionOf(daylight.zenith());
        dawnPosition = positionOf(daylight.dawn());
        duskPosition = positionOf(daylight.dusk());
    }

    function sunrise() as Float? {
        return sunrisePosition;
    }

    function sunset() as Float? {
        return sunsetPosition;
    }

    function zenith() as Float? {
        return zenithPosition;
    }

    function dawn() as Float? {
        return dawnPosition;
    }

    function dusk() as Float? {
        return duskPosition;
    }

    //! The color at a dial position
    function colorAt(degrees as Numeric) as Number {
        var rise = sunrisePosition;
        var set = sunsetPosition;

        if ((rise == null) || (set == null)) {
            return FALLBACK_COLOR;
        }

        if (isBetween(degrees, rise, set)) {
            return DAY_COLOR;
        }

        return isTwilightAt(degrees) ? TWILIGHT_COLOR : NIGHT_COLOR;
    }

    private function isTwilightAt(degrees as Numeric) as Boolean {
        var dawn = dawnPosition;
        var dusk = duskPosition;
        var rise = sunrisePosition;
        var set = sunsetPosition;

        if ((dawn == null) || (dusk == null) || (rise == null) || (set == null)) {
            return false;
        }

        return isBetween(degrees, dawn, rise) || isBetween(degrees, set, dusk);
    }

    //! Clockwise from one position, up to but not including the other; the
    //! span may run across the dial's zero
    private function isBetween(degrees as Numeric, from as Float, to as Float) as Boolean {
        return (from <= to)
            ? ((degrees >= from) && (degrees < to))
            : ((degrees >= from) || (degrees < to));
    }

    private function positionOf(minute as Number?) as Float? {
        if (minute == null) {
            return null;
        }

        return Dial.positionOfMinute(minute);
    }
}

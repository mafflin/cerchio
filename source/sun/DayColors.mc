import Toybox.Graphics;
import Toybox.Lang;

//! The rim's colors: amber from sunrise to sunset, sky blue after. The
//! fallback color until the sun is known.
class DayColors {

    private const DAY_COLOR = Palette.AMBER;
    private const NIGHT_COLOR = Palette.SKY;

    private var daylight as Daylight;

    //! Until the sun is known
    private var fallbackColor as Number = Graphics.COLOR_WHITE;

    //! Sunrise, sunset and solar noon on the dial, null when not known
    private var sunrisePosition as Float? = null;
    private var sunsetPosition as Float? = null;
    private var zenithPosition as Float? = null;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
    }

    function setFallbackColor(fallbackColor as Number) as Void {
        self.fallbackColor = fallbackColor;
    }

    //! Once per full update, after the daylight has refreshed
    function refresh() as Void {
        var sunrise = daylight.sunrise();
        var sunset = daylight.sunset();
        var zenith = daylight.zenith();

        if ((sunrise == null) || (sunset == null) || (zenith == null)) {
            sunrisePosition = null;
            sunsetPosition = null;
            zenithPosition = null;
            return;
        }

        sunrisePosition = Dial.positionOfMinute(sunrise);
        sunsetPosition = Dial.positionOfMinute(sunset);
        zenithPosition = Dial.positionOfMinute(zenith);
    }

    //! On the dial, null until the sun is known
    function sunrise() as Float? {
        return sunrisePosition;
    }

    function sunset() as Float? {
        return sunsetPosition;
    }

    function zenith() as Float? {
        return zenithPosition;
    }

    //! The color at a dial position
    function colorAt(degrees as Numeric) as Number {
        var isDay = isDayAt(degrees);

        if (isDay == null) {
            return fallbackColor;
        }

        return isDay ? DAY_COLOR : NIGHT_COLOR;
    }

    //! Null until the sun is known
    private function isDayAt(degrees as Numeric) as Boolean? {
        var rise = sunrisePosition;
        var set = sunsetPosition;

        if ((rise == null) || (set == null)) {
            return null;
        }

        // The day runs across the dial's zero whenever sunrise lies past sunset.
        return (rise <= set)
            ? ((degrees >= rise) && (degrees < set))
            : ((degrees >= rise) || (degrees < set));
    }
}

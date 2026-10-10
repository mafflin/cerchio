import Toybox.Graphics;
import Toybox.Lang;

//! The rim's colors: amber from sunrise to sunset, orange in the twilight
//! either side, sky blue through the night. The fallback color until the sun
//! is known; no orange while dawn and dusk are not.
class DayColors {

    private const DAY_COLOR = Palette.AMBER;
    private const TWILIGHT_COLOR = Palette.TWILIGHT;
    private const NIGHT_COLOR = Palette.SKY;

    //! Until the sun is known
    private const FALLBACK_COLOR = Graphics.COLOR_WHITE;

    private var daylight as Daylight;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
    }

    //! From sunrise to sunset
    function dayColor() as Number {
        return DAY_COLOR;
    }

    //! The color at a minute past midnight
    function colorAt(minute as Number) as Number {
        var up = daylight.isUpAt(minute);

        if (up == null) {
            return FALLBACK_COLOR;
        }

        if (up) {
            return DAY_COLOR;
        }

        return daylight.isTwilightAt(minute) ? TWILIGHT_COLOR : NIGHT_COLOR;
    }
}

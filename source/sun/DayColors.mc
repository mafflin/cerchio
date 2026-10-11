import Toybox.Graphics;
import Toybox.Lang;

//! The rim's colors: amber from sunrise to sunset, orange in the twilight
//! either side, sky blue through the night. The fallback color until the sun
//! is known; no orange while dawn and dusk are not.
module DayColors {

    //! From sunrise to sunset
    const DAY = Palette.AMBER;

    //! From dawn to sunrise, and from sunset to dusk; the sun field's icon
    //! then too
    const TWILIGHT = Palette.ORANGE;

    //! From dusk to dawn, or sunset to sunrise without them
    const NIGHT = Palette.SKY;

    //! Until the sun is known
    const FALLBACK = Graphics.COLOR_WHITE;
}

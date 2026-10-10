import Toybox.Lang;

//! The wind off the weather: bearing, whether it is calm, strength in three
//! steps, and the color for each step.
class WindReading {

    //! The weather reports wind speed in m/s; the limits read as km/h
    private const KMH_PER_MS = 3.6;
    private const LIGHT_LIMIT_KMH = 20;
    private const MODERATE_LIMIT_KMH = 40;

    //! Below this the speed rounds to 0 km/h
    private const CALM_LIMIT_KMH = 0.5;

    private const LIGHT = 0;
    private const MODERATE = 1;
    private const STRONG = 2;

    //! A light wind is the ordinary case and keeps its drawer's color
    private const MODERATE_COLOR = Palette.AMBER;
    private const STRONG_COLOR = Palette.ORANGE;

    //! Whether the phone has sent any weather
    private var weatherKnown as Boolean = false;

    //! Where the wind blows from, north up; null when unknown
    private var currentBearing as Number? = null;

    private var calm as Boolean = false;
    private var strength as Number = LIGHT;

    function initialize() {
    }

    //! Once per draw of the row, off the weather as CurrentWeather has it
    function refresh() as Void {
        currentBearing = null;
        calm = false;
        strength = LIGHT;

        var conditions = CurrentWeather.conditions();

        weatherKnown = (conditions != null);

        if (conditions == null) {
            return;
        }

        var bearing = conditions.windBearing;

        if (bearing == null) {
            return;
        }

        var speed = conditions.windSpeed;

        currentBearing = bearing;
        calm = (speed != null) ? ((speed * KMH_PER_MS) < CALM_LIMIT_KMH) : false;
        strength = strengthFor(speed);
    }

    //! False on a watch without weather, or before the phone has sent any
    function hasWeather() as Boolean {
        return weatherKnown;
    }

    function bearing() as Number? {
        return currentBearing;
    }

    //! A bearing without a speed is not calm
    function isCalm() as Boolean {
        return calm;
    }

    //! Amber when moderate, orange when strong, the given color otherwise
    function colorFor(lightColor as Number) as Number {
        if (strength == STRONG) {
            return STRONG_COLOR;
        }

        if (strength == MODERATE) {
            return MODERATE_COLOR;
        }

        return lightColor;
    }

    //! A bearing without a speed counts as light
    private function strengthFor(speed as Numeric?) as Number {
        if (speed == null) {
            return LIGHT;
        }

        var kmh = speed * KMH_PER_MS;

        if (kmh <= LIGHT_LIMIT_KMH) {
            return LIGHT;
        }

        if (kmh <= MODERATE_LIMIT_KMH) {
            return MODERATE;
        }

        return STRONG;
    }
}

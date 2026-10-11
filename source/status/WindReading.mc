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

    //! m/s, null when unknown
    private var speed as Numeric? = null;

    //! Once a minute: the phone refills the weather by the hour at best
    private var minuteGate as MinuteGate;

    function initialize() {
        minuteGate = new MinuteGate();
    }

    //! Once per draw of the row; reads at most once a minute
    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        currentBearing = null;
        speed = null;

        var conditions = CurrentWeather.conditions();

        weatherKnown = (conditions != null);

        if (conditions == null) {
            return;
        }

        var bearing = conditions.windBearing;

        if (bearing == null) {
            return;
        }

        currentBearing = bearing;
        speed = conditions.windSpeed;
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
        return isCalmAt(speed);
    }

    //! Amber when moderate, orange when strong, the given color otherwise
    function colorFor(lightColor as Number) as Number {
        return colorAt(speed, lightColor);
    }

    //! Under half a km/h; null is not calm
    function isCalmAt(windSpeed as Numeric?) as Boolean {
        return (windSpeed != null) ? ((windSpeed * KMH_PER_MS) < CALM_LIMIT_KMH) : false;
    }

    //! colorFor() at a speed in m/s
    function colorAt(windSpeed as Numeric?, lightColor as Number) as Number {
        var strength = strengthFor(windSpeed);

        if (strength == STRONG) {
            return STRONG_COLOR;
        }

        if (strength == MODERATE) {
            return MODERATE_COLOR;
        }

        return lightColor;
    }

    //! A bearing without a speed counts as light
    private function strengthFor(windSpeed as Numeric?) as Number {
        if (windSpeed == null) {
            return LIGHT;
        }

        var kmh = windSpeed * KMH_PER_MS;

        if (kmh <= LIGHT_LIMIT_KMH) {
            return LIGHT;
        }

        if (kmh <= MODERATE_LIMIT_KMH) {
            return MODERATE;
        }

        return STRONG;
    }
}

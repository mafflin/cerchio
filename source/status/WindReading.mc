import Toybox.Lang;

class WindReading {

    //! Speed comes in m/s, limits are km/h
    private const KMH_PER_MS = 3.6;
    private const LIGHT_LIMIT_KMH = 20;
    private const MODERATE_LIMIT_KMH = 40;

    //! Rounds to 0 km/h
    private const CALM_LIMIT_KMH = 0.5;

    private const LIGHT = 0;
    private const MODERATE = 1;
    private const STRONG = 2;

    private const MODERATE_COLOR = Palette.AMBER;
    private const STRONG_COLOR = Palette.ORANGE;

    private var weatherKnown as Boolean = false;

    //! Where it blows from
    private var currentBearing as Number? = null;

    //! m/s
    private var speed as Numeric? = null;

    private var minuteGate as MinuteGate;

    function initialize() {
        minuteGate = new MinuteGate();
    }

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

    function hasWeather() as Boolean {
        return weatherKnown;
    }

    function bearing() as Number? {
        return currentBearing;
    }

    function isCalm() as Boolean {
        return isCalmAt(speed);
    }

    function colorFor(lightColor as Number) as Number {
        return colorAt(speed, lightColor);
    }

    //! Null is not calm
    function isCalmAt(windSpeed as Numeric?) as Boolean {
        return (windSpeed != null) ? ((windSpeed * KMH_PER_MS) < CALM_LIMIT_KMH) : false;
    }

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

    //! Unknown speed counts as light
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

import Toybox.Lang;

class WindReading {

    //! Speed comes in m/s, limits are km/h
    private const KMH_PER_MS = 3.6;

    //! Beaufort 4, 6 and 8
    private const MODERATE_FROM_KMH = 20;
    private const STRONG_FROM_KMH = 39;
    private const GALE_FROM_KMH = 62;

    //! Beaufort 0
    private const CALM_LIMIT_KMH = 1;

    private const LIGHT = 0;
    private const MODERATE = 1;
    private const STRONG = 2;
    private const GALE = 3;

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

        if (strength == GALE) {
            return DayColors.TWILIGHT;
        }

        if (strength == STRONG) {
            return DayColors.DAY;
        }

        if (strength == MODERATE) {
            return DayColors.NIGHT;
        }

        return lightColor;
    }

    //! Unknown speed counts as light
    private function strengthFor(windSpeed as Numeric?) as Number {
        if (windSpeed == null) {
            return LIGHT;
        }

        var kmh = windSpeed * KMH_PER_MS;

        if (kmh < MODERATE_FROM_KMH) {
            return LIGHT;
        }

        if (kmh < STRONG_FROM_KMH) {
            return MODERATE;
        }

        if (kmh < GALE_FROM_KMH) {
            return STRONG;
        }

        return GALE;
    }
}

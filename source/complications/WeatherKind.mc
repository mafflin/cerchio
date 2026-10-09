import Toybox.Complications;
import Toybox.Lang;

//! The weather: an icon for the conditions, beside the temperature and
//! where the wind blows from with its speed in whole km/h, 12°SW13. Any of
//! them left out when not known, and a dash when none is. The complication's
//! own value goes unread; all of it comes off the weather itself.
class WeatherKind extends FieldKind {

    //! Nothing known: the field still shows
    private const UNKNOWN = "--";

    //! Clockwise from north, each the middle of a slice of the circle
    private const COMPASS_POINTS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];

    private var conditionIcon as WeatherIcon;

    function initialize() {
        FieldKind.initialize(null);
        conditionIcon = new WeatherIcon();
    }

    function icon() as Icon? {
        return conditionIcon;
    }

    function text(complication as Complications.Complication) as String {
        var conditions = CurrentWeather.conditions();

        conditionIcon.setCondition((conditions != null) ? conditions.condition : null);

        if (conditions == null) {
            return UNKNOWN;
        }

        var temperature = conditions.temperature;
        var degrees = (temperature != null) ? ValueFormat.temperature(temperature.toFloat()) : ValueFormat.NOTHING;
        var wind = windOf(conditions.windBearing, conditions.windSpeed);

        var shown = degrees + wind;

        return (shown.length() > 0) ? shown : UNKNOWN;
    }

    //! Where it blows from and its speed, SW13, either alone; empty for
    //! neither
    private function windOf(bearing as Number?, speed as Float?) as String {
        var point = (bearing != null) ? compassPoint(bearing) : ValueFormat.NOTHING;

        return (speed != null) ? (point + ValueFormat.rounded(speed * CurrentWeather.KMH_PER_MS)) : point;
    }

    //! The nearest of the points to a bearing in degrees
    private function compassPoint(bearing as Number) as String {
        var count = COMPASS_POINTS.size();
        var degrees = ((bearing % Dial.DEGREES_PER_CIRCLE) + Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
        var index = (((degrees * count) + Dial.HALF_TURN) / Dial.DEGREES_PER_CIRCLE) % count;

        return COMPASS_POINTS[index] as String;
    }
}

import Toybox.Complications;
import Toybox.Lang;

//! The weather stands for the wind: where it blows from and its speed in
//! whole km/h, SW12, beside a fan. Either alone when the other is not known,
//! and a dash when neither is. The weather's own value, the conditions, goes
//! unread.
class WindKind extends FieldKind {

    //! Neither the bearing nor the speed: the field still shows
    private const UNKNOWN = "--";

    //! Clockwise from north, each the middle of a slice of the circle
    private const COMPASS_POINTS = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];

    //! The weather reports m/s
    private const KMH_PER_MS = 3.6;

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    function text(complication as Complications.Complication) as String {
        var conditions = CurrentWeather.conditions();

        if (conditions == null) {
            return UNKNOWN;
        }

        var bearing = conditions.windBearing;
        var speed = conditions.windSpeed;

        if ((bearing == null) && (speed == null)) {
            return UNKNOWN;
        }

        var point = (bearing != null) ? compassPoint(bearing) : ValueFormat.NOTHING;

        return (speed != null) ? (point + ValueFormat.rounded(speed * KMH_PER_MS)) : point;
    }

    //! The nearest of the points to a bearing in degrees
    private function compassPoint(bearing as Number) as String {
        var count = COMPASS_POINTS.size();
        var degrees = ((bearing % Dial.DEGREES_PER_CIRCLE) + Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;
        var index = (((degrees * count) + Dial.HALF_TURN) / Dial.DEGREES_PER_CIRCLE) % count;

        return COMPASS_POINTS[index] as String;
    }
}

import Toybox.Complications;
import Toybox.Lang;

//! Reads Weather directly; the complication's value goes unused
class WeatherKind extends FieldKind {

    private const UNKNOWN = "--";

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

        return (temperature != null) ? ValueFormat.temperature(temperature.toFloat()) : UNKNOWN;
    }
}

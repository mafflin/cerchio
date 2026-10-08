import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

//! Always Celsius, whatever the watch shows; whole degrees in its unit
class TemperatureKind extends FieldKind {

    private const FAHRENHEIT_PER_CELSIUS = 1.8;
    private const FAHRENHEIT_AT_ZERO = 32.0;

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        var degrees = ValueFormat.decimal(value);

        if (Clock.settings().temperatureUnits == System.UNIT_STATUTE) {
            degrees = (degrees * FAHRENHEIT_PER_CELSIUS) + FAHRENHEIT_AT_ZERO;
        }

        return ValueFormat.rounded(degrees) + ValueFormat.DEGREE;
    }
}

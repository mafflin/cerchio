import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

module ValueFormat {

    const NOTHING = "";
    const DEGREE = "°";

    const LEADING_FORMAT = "%d";
    const TRAILING_FORMAT = "%02d";

    const DECIMAL_FORMAT = "%.1f";

    const FAHRENHEIT_PER_CELSIUS = 1.8;
    const FAHRENHEIT_AT_ZERO = 32.0;
    const VALUE_UNIT_FORMAT = "$1$$2$";

    function withUnit(value as Complications.Value, unit as Complications.Unit or String or Null) as String {
        var text = number(value);

        if (!(unit instanceof Lang.String)) {
            return text;
        }

        if (unit.length() == 0) {
            return text;
        }

        return Lang.format(VALUE_UNIT_FORMAT, [text, unit]);
    }

    function number(value as Complications.Value) as String {
        if ((value instanceof Lang.Float) || (value instanceof Lang.Double)) {
            return decimal(value).format(DECIMAL_FORMAT);
        }

        return value.toString();
    }

    function pair(format as String, leading as Number, trailing as Number) as String {
        return Lang.format(format, [leading.format(LEADING_FORMAT), trailing.format(TRAILING_FORMAT)]);
    }

    function whole(value as Complications.Value) as String {
        return rounded(decimal(value));
    }

    function temperature(celsius as Float) as String {
        var degrees = celsius;

        if (Clock.settings().temperatureUnits == System.UNIT_STATUTE) {
            degrees = (degrees * FAHRENHEIT_PER_CELSIUS) + FAHRENHEIT_AT_ZERO;
        }

        return rounded(degrees) + DEGREE;
    }

    function rounded(amount as Float) as String {
        return Numbers.round(amount).format(LEADING_FORMAT);
    }

    function decimal(value as Complications.Value) as Float {
        if (value instanceof Lang.Float) {
            return value;
        }

        if (value instanceof Lang.Double) {
            return value.toFloat();
        }

        if (value instanceof Lang.Long) {
            return value.toFloat();
        }

        if (value instanceof Lang.Number) {
            return value.toFloat();
        }

        return 0.0;
    }

    function wholeNumber(value as Complications.Value) as Number {
        if (value instanceof Lang.Number) {
            return value;
        }

        return decimal(value).toNumber();
    }
}

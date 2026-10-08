import Toybox.Graphics;
import Toybox.Lang;

//! The seconds with the numerals: the numeral nearest the second's place on
//! the dial, picked out a font step larger in the accent color. It moves on
//! every two or three seconds.
class SecondsNumeral extends SecondsMarker {

    private var numerals as RimNumerals;

    function initialize(numerals as RimNumerals) {
        SecondsMarker.initialize();
        self.numerals = numerals;
    }

    //! The numeral whose place is nearest the second's: seconds run round
    //! from the top, the hours from midnight at the bottom
    protected function positionAt(second as Number) as Number {
        var degrees = second * Dial.DEGREES_PER_SECOND;
        var fromMidnight = (degrees - Dial.MIDNIGHT_DEGREES + Dial.DEGREES_PER_CIRCLE) % Dial.DEGREES_PER_CIRCLE;

        return ((fromMidnight + (Dial.DEGREES_PER_HOUR / 2)) / Dial.DEGREES_PER_HOUR) % Dial.HOURS;
    }

    protected function paintAt(dc as Dc, position as Number) as Void {
        numerals.drawHighlight(dc, position, color);
    }

    protected function boxOf(position as Number) as Array<Number> {
        return numerals.boxOf(position);
    }
}

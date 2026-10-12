import Toybox.Lang;
import Toybox.Math;

module Numbers {

    function min(first as Number, second as Number) as Number {
        return (first < second) ? first : second;
    }

    function max(first as Number, second as Number) as Number {
        return (first > second) ? first : second;
    }

    function round(value as Decimal) as Number {
        return Math.round(value).toNumber();
    }

    //! [from, to) on a circle; may wrap past zero
    function isBetween(value as Numeric, from as Numeric, to as Numeric) as Boolean {
        return (from <= to)
            ? ((value >= from) && (value < to))
            : ((value >= from) || (value < to));
    }
}

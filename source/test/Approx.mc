import Toybox.Lang;
import Toybox.Test;

//! Comparing worked out numbers, for the tests; left out of release builds
(:debug)
module Approx {

    //! Within tolerance; false for null
    function isNear(value as Decimal?, expected as Decimal, tolerance as Decimal) as Boolean {
        if (value == null) {
            return false;
        }

        return (value - expected).abs() <= tolerance;
    }

    //! Both null, or both within tolerance
    function isSame(value as Float?, expected as Float?, tolerance as Decimal) as Boolean {
        if (expected == null) {
            return value == null;
        }

        return isNear(value, expected, tolerance);
    }

    function check(isTrue as Boolean, message as String) as Void {
        Test.assertMessage(isTrue, message);
    }

    //! Exactly equal, both shown when not
    function checkEqual(actual as Object, expected as Object, message as String) as Void {
        Test.assertEqualMessage(actual, expected, message + ": got " + actual + ", expected " + expected);
    }
}

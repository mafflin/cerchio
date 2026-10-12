import Toybox.Lang;
import Toybox.Test;

(:test)
module ClockTest {

    (:test)
    function wrapMinutes(logger as Test.Logger) as Boolean {
        Approx.checkEqual(Clock.wrapMinutes(0), 0, "midnight");
        Approx.checkEqual(Clock.wrapMinutes(-1), Clock.MINUTES_PER_DAY - 1, "a minute before midnight");
        Approx.checkEqual(Clock.wrapMinutes(Clock.MINUTES_PER_DAY), 0, "a day on");
        Approx.checkEqual(Clock.wrapMinutes(Clock.MINUTES_PER_DAY + 60), 60, "past a day");
        Approx.checkEqual(Clock.wrapMinutes(-Clock.MINUTES_PER_DAY), 0, "a day back");

        return true;
    }

    (:test)
    function twelveHour(logger as Test.Logger) as Boolean {
        Approx.checkEqual(Clock.twelveHour(0), 12, "midnight");
        Approx.checkEqual(Clock.twelveHour(1), 1, "1 am");
        Approx.checkEqual(Clock.twelveHour(11), 11, "11 am");
        Approx.checkEqual(Clock.twelveHour(12), 12, "noon");
        Approx.checkEqual(Clock.twelveHour(13), 1, "1 pm");
        Approx.checkEqual(Clock.twelveHour(23), 11, "11 pm");

        return true;
    }

    (:test)
    function isMorning(logger as Test.Logger) as Boolean {
        Approx.check(Clock.isMorning(0), "midnight");
        Approx.check(Clock.isMorning(11), "11");
        Approx.check(!Clock.isMorning(12), "noon");
        Approx.check(!Clock.isMorning(23), "23");

        return true;
    }

    (:test)
    function displayHour(logger as Test.Logger) as Boolean {
        var is24Hour = Clock.settings().is24Hour;

        logger.debug("24 hour: " + is24Hour);
        Approx.checkEqual(Clock.displayHour(15), is24Hour ? 15 : 3, "15");
        Approx.checkEqual(Clock.displayHour(0), is24Hour ? 0 : 12, "midnight");

        return true;
    }

    (:test)
    function minuteOfDay(logger as Test.Logger) as Boolean {
        var time = Clock.now();

        Approx.checkEqual(Clock.minuteOfDay(), (time.hour * Clock.MINUTES_PER_HOUR) + time.min, "as last read");

        return true;
    }
}

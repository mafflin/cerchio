import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;

//! Latitude stubbed; dawn and dusk checked against Twilight
(:test)
module DaylightTest {

    const SIX = 6 * 60;
    const NOON = 12 * 60;
    const EIGHTEEN = 18 * 60;

    (:test)
    function sunUnknown(logger as Test.Logger) as Boolean {
        var stub = new LatitudeStub(50.0);
        var daylight = daylightWith(stub);

        daylight.update(null, null, NOON, 0.0);

        Approx.check(daylight.isUpAt(NOON) == null, "up unknown");
        Approx.check(daylight.zenith() == null, "no zenith");
        Approx.check((daylight.dawn() == null) && (daylight.dusk() == null), "no dawn or dusk");
        Approx.check(!daylight.isTwilightAt(NOON), "no twilight");
        Approx.checkEqual(stub.reads, 0, "latitude reads");

        return true;
    }

    //! 06:00–18:00, 50° N, equinox
    (:test)
    function ordinaryDay(logger as Test.Logger) as Boolean {
        var daylight = daylightWith(new LatitudeStub(50.0));

        daylight.update(SIX, EIGHTEEN, NOON, 0.0);

        var fromNoon = expectedFromNoon(SIX, EIGHTEEN, 50.0, 0.0);

        logger.debug("dawn " + daylight.dawn() + ", dusk " + daylight.dusk() + ", from noon " + fromNoon);
        Approx.checkEqual(daylight.zenith() as Number, NOON, "zenith");
        Approx.checkEqual(daylight.dawn() as Number, NOON - fromNoon, "dawn");
        Approx.checkEqual(daylight.dusk() as Number, NOON + fromNoon, "dusk");

        var dawn = daylight.dawn() as Number;
        var dusk = daylight.dusk() as Number;

        Approx.check(daylight.isUpAt(SIX) == true, "up at sunrise");
        Approx.check(daylight.isUpAt(EIGHTEEN) == false, "down at sunset");
        Approx.check(daylight.isUpAt(0) == false, "down at midnight");
        Approx.check(!daylight.isTwilightAt(dawn - 1), "night before dawn");
        Approx.check(daylight.isTwilightAt(dawn), "twilight from dawn");
        Approx.check(daylight.isTwilightAt(SIX - 1), "twilight up to sunrise");
        Approx.check(!daylight.isTwilightAt(SIX), "day from sunrise");
        Approx.check(daylight.isTwilightAt(EIGHTEEN), "twilight from sunset");
        Approx.check(daylight.isTwilightAt(dusk - 1), "twilight up to dusk");
        Approx.check(!daylight.isTwilightAt(dusk), "night from dusk");

        return true;
    }

    //! 06:00–18:00: noon 11:45–12:15
    (:test)
    function zenithWindow(logger as Test.Logger) as Boolean {
        var daylight = daylightWith(new LatitudeStub(50.0));
        var reach = daylight.ZENITH_MINUTES;

        Approx.check(!daylight.isZenithAt(NOON), "not before the sun is known");

        daylight.update(SIX, EIGHTEEN, NOON, 0.0);

        Approx.check(daylight.isZenithAt(NOON), "at noon");
        Approx.check(daylight.isZenithAt(NOON - reach), "from a quarter before");
        Approx.check(daylight.isZenithAt(NOON + reach), "through a quarter after");
        Approx.check(!daylight.isZenithAt(NOON - reach - 1), "not before");
        Approx.check(!daylight.isZenithAt(NOON + reach + 1), "not after");

        return true;
    }

    //! 23:00–01:00
    (:test)
    function zenithAcrossMidnight(logger as Test.Logger) as Boolean {
        var daylight = daylightWith(new LatitudeStub(50.0));
        var reach = daylight.ZENITH_MINUTES;

        daylight.update(23 * 60, 60, NOON, 0.0);

        Approx.check(daylight.isZenithAt(0), "at midnight");
        Approx.check(daylight.isZenithAt(Clock.MINUTES_PER_DAY - reach), "before midnight");
        Approx.check(daylight.isZenithAt(reach), "after midnight");
        Approx.check(!daylight.isZenithAt(NOON), "not at clock noon");

        return true;
    }

    //! 23:00–13:00: as far west in a time zone as clocks get
    (:test)
    function acrossMidnight(logger as Test.Logger) as Boolean {
        var rise = 23 * 60;
        var set = 13 * 60;
        var declination = Math.toRadians(15.0);
        var daylight = daylightWith(new LatitudeStub(50.0));

        daylight.update(rise, set, NOON, declination);

        var fromNoon = expectedFromNoon(rise, set, 50.0, declination);

        Approx.checkEqual(daylight.zenith() as Number, SIX, "zenith");
        Approx.checkEqual(daylight.dawn() as Number, Clock.wrapMinutes(SIX - fromNoon), "dawn");
        Approx.checkEqual(daylight.dusk() as Number, Clock.wrapMinutes(SIX + fromNoon), "dusk");
        Approx.check(daylight.isUpAt(0) == true, "up at midnight");
        Approx.check(daylight.isUpAt(15 * 60) == false, "down at 15:00");
        Approx.check(daylight.isTwilightAt(rise - 1), "twilight before sunrise");
        Approx.check(daylight.isTwilightAt(set), "twilight from sunset");

        return true;
    }

    //! 65° N, June solstice: dawn and dusk meet at midnight
    (:test)
    function whiteNight(logger as Test.Logger) as Boolean {
        var rise = 150;
        var set = 1290;
        var daylight = daylightWith(new LatitudeStub(65.0));

        daylight.update(rise, set, NOON, Math.toRadians(Twilight.TILT));

        Approx.checkEqual(daylight.dawn() as Number, 0, "dawn");
        Approx.checkEqual(daylight.dusk() as Number, 0, "dusk");
        Approx.check(daylight.isTwilightAt(set), "at sunset");
        Approx.check(daylight.isTwilightAt(0), "at midnight");
        Approx.check(daylight.isTwilightAt(rise - 1), "up to sunrise");
        Approx.check(!daylight.isTwilightAt(NOON), "not at noon");

        return true;
    }

    //! A latitude that doesn't fit the sun: none rather than wrong
    (:test)
    function twilightShorterThanDay(logger as Test.Logger) as Boolean {
        var daylight = daylightWith(new LatitudeStub(0.0));

        daylight.update(SIX, 19 * 60, NOON, 0.0);

        Approx.check((daylight.dawn() == null) && (daylight.dusk() == null), "no dawn or dusk");
        Approx.check(!daylight.isTwilightAt(SIX - 1), "no twilight");
        Approx.check(daylight.isUpAt(NOON) == true, "the sun still up");

        return true;
    }

    (:test)
    function noLatitude(logger as Test.Logger) as Boolean {
        var declination = Math.toRadians(15.0);
        var daylight = daylightWith(new LatitudeStub(null));

        daylight.update(SIX, 19 * 60, NOON, declination);

        var fromNoon = Twilight.minutesFromNoon(13 * 60, null, declination);

        logger.debug("estimated from noon " + fromNoon);
        Approx.check(fromNoon != null, "an estimate");
        Approx.checkEqual(daylight.dawn() as Number, (daylight.zenith() as Number) - (fromNoon as Number), "estimated dawn");

        var nearEquinox = daylightWith(new LatitudeStub(null));

        nearEquinox.update(SIX, EIGHTEEN, NOON, 0.0);
        Approx.check(nearEquinox.dawn() == null, "no estimate near an equinox");

        return true;
    }

    (:test)
    function latitudeReadWithTheSun(logger as Test.Logger) as Boolean {
        var stub = new LatitudeStub(50.0);
        var daylight = daylightWith(stub);

        daylight.update(SIX, EIGHTEEN, NOON, 0.0);
        Approx.checkEqual(stub.reads, 1, "read with the first sun");

        daylight.update(SIX, EIGHTEEN, NOON + 1, 0.0);
        daylight.update(SIX, EIGHTEEN, NOON + 120, 0.0);
        Approx.checkEqual(stub.reads, 1, "known: not read again");

        daylight.update(SIX + 1, EIGHTEEN - 1, NOON + 121, 0.0);
        Approx.checkEqual(stub.reads, 2, "read again when the sun moves");

        return true;
    }

    (:test)
    function latitudeRetriedHourly(logger as Test.Logger) as Boolean {
        var stub = new LatitudeStub(null);
        var daylight = daylightWith(stub);

        daylight.update(SIX, EIGHTEEN, NOON, 0.0);
        Approx.checkEqual(stub.reads, 1, "first ask");
        Approx.check(daylight.dawn() == null, "no dawn without a latitude near an equinox");

        daylight.update(SIX, EIGHTEEN, NOON + 1, 0.0);
        daylight.update(SIX, EIGHTEEN, NOON + 59, 0.0);
        Approx.checkEqual(stub.reads, 1, "not within the hour");

        stub.value = 50.0;
        daylight.update(SIX, EIGHTEEN, NOON + 60, 0.0);
        Approx.checkEqual(stub.reads, 2, "asked again after an hour");
        Approx.checkEqual(daylight.dawn() as Number, NOON - expectedFromNoon(SIX, EIGHTEEN, 50.0, 0.0), "dawn once it came");

        daylight.update(SIX, EIGHTEEN, NOON + 180, 0.0);
        Approx.checkEqual(stub.reads, 2, "known: no more asking");

        return true;
    }

    (:test)
    function latitudeRetriedAcrossMidnight(logger as Test.Logger) as Boolean {
        var stub = new LatitudeStub(null);
        var daylight = daylightWith(stub);

        daylight.update(SIX, EIGHTEEN, 1430, 0.0);
        daylight.update(SIX, EIGHTEEN, 10, 0.0);
        Approx.checkEqual(stub.reads, 1, "20 minutes on");

        daylight.update(SIX, EIGHTEEN, 50, 0.0);
        Approx.checkEqual(stub.reads, 2, "an hour on");

        return true;
    }

    (:test)
    function lastLatitudeStands(logger as Test.Logger) as Boolean {
        var stub = new LatitudeStub(50.0);
        var daylight = daylightWith(stub);

        daylight.update(SIX, EIGHTEEN, NOON, 0.0);

        stub.value = null;
        daylight.update(SIX + 1, EIGHTEEN - 1, NOON + 1, 0.0);

        Approx.checkEqual(stub.reads, 2, "asked with the moved sun");
        Approx.checkEqual(daylight.dawn() as Number, NOON - expectedFromNoon(SIX + 1, EIGHTEEN - 1, 50.0, 0.0), "dawn by the last latitude");

        return true;
    }

    //! Without simulator weather, only checks nothing breaks
    (:test)
    function defaultSource(logger as Test.Logger) as Boolean {
        var declination = Math.toRadians(15.0);
        var daylight = new Daylight();
        var latitude = Latitude.read();

        daylight.update(SIX, EIGHTEEN, NOON, declination);

        logger.debug("latitude " + latitude + ", dawn " + daylight.dawn());

        if (latitude != null) {
            Approx.checkEqual(daylight.dawn() as Number, NOON - expectedFromNoon(SIX, EIGHTEEN, latitude, declination), "dawn by Latitude.read()");
        }

        return true;
    }

    (:debug)
    function daylightWith(stub as LatitudeStub) as Daylight {
        var daylight = new Daylight();

        daylight.setLatitudeSource(stub.method(:read));

        return daylight;
    }

    (:debug)
    function expectedFromNoon(rise as Number, set as Number, latitude as Float, declination as Decimal) as Number {
        return Twilight.minutesFromNoon(Clock.wrapMinutes(set - rise), latitude, declination) as Number;
    }
}

//! Counts reads
(:debug)
class LatitudeStub {

    var value as Float?;
    var reads as Number = 0;

    function initialize(value as Float?) {
        self.value = value;
    }

    function read() as Float? {
        reads++;

        return value;
    }
}

import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

(:test)
module FieldKindsTest {

    (:test)
    function formattedKinds(logger as Test.Logger) as Boolean {
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_ALTITUDE) instanceof AltitudeKind, "altitude");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_BATTERY) instanceof PercentKind, "battery");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE) instanceof TemperatureKind, "temperature");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_CURRENT_WEATHER) instanceof WeatherKind, "weather");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_HIGH_LOW_TEMPERATURE) instanceof HighLowKind, "high and low");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_RECOVERY_TIME) instanceof HoursKind, "recovery");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_SUNSET) instanceof SunKind, "sunset");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE) instanceof DistanceKind, "bike");
        Approx.check(FieldKinds.of(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE) instanceof DistanceKind, "run");

        return true;
    }

    //! Shown as the system gives them, with an icon
    (:test)
    function plainKindsWithIcon(logger as Test.Logger) as Boolean {
        checkPlain(Complications.COMPLICATION_TYPE_BODY_BATTERY, true, "body battery");
        checkPlain(Complications.COMPLICATION_TYPE_CALORIES, true, "calories");
        checkPlain(Complications.COMPLICATION_TYPE_HEART_RATE, true, "heart rate");
        checkPlain(Complications.COMPLICATION_TYPE_INTENSITY_MINUTES, true, "intensity minutes");
        checkPlain(Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT, true, "notifications");
        checkPlain(Complications.COMPLICATION_TYPE_STEPS, true, "steps");

        return true;
    }

    //! The dates, and anything unknown: plain, without an icon
    (:test)
    function plainKindsWithoutIcon(logger as Test.Logger) as Boolean {
        checkPlain(null, false, "none");
        checkPlain(Complications.COMPLICATION_TYPE_INVALID, false, "invalid");
        checkPlain(Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY, false, "weekday and day");

        return true;
    }

    //! Not one of the subclasses, and with or without an icon
    (:debug)
    function checkPlain(type as Complications.Type?, hasIcon as Boolean, name as String) as Void {
        var kind = FieldKinds.of(type);
        var isSubclass = (kind instanceof AltitudeKind) || (kind instanceof PercentKind)
            || (kind instanceof TemperatureKind) || (kind instanceof WeatherKind)
            || (kind instanceof HighLowKind) || (kind instanceof HoursKind)
            || (kind instanceof SunKind) || (kind instanceof DistanceKind);

        Approx.check(!isSubclass, name + " is plain");
        Approx.check((kind.icon() != null) == hasIcon, name + (hasIcon ? " has an icon" : " has no icon"));
        Approx.check(!kind.followsClock(), name + " goes by the system's updates");
    }
}

import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

//! Comes in meters; shown in km or mi, unitless
class DistanceKind extends FieldKind {

    private const METERS_PER_KILOMETER = 1000.0;
    private const METERS_PER_MILE = 1609.344;

    private const DISTANCE_FORMAT = "%.1f";

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    //! A week without a run comes as null, so show 0
    function text(complication as Complications.Complication) as String {
        var value = complication.value;

        return format((value != null) ? value : 0, complication);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        var meters = ValueFormat.decimal(value);
        var perUnit = (Clock.settings().distanceUnits == System.UNIT_STATUTE) ? METERS_PER_MILE : METERS_PER_KILOMETER;

        return (meters / perUnit).format(DISTANCE_FORMAT);
    }
}

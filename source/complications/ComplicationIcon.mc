import Toybox.Complications;
import Toybox.Lang;

//! An icon per complication type, in place of a name. One case per type in
//! watchface.xml, same order. A type above minApiLevel cannot be named here,
//! which keeps sleep score off both lists. The dates read as what they are
//! and get none.
module ComplicationIcon {

    //! A new icon for a type, null for none. The weather stands for the wind,
    //! whose arrow is drawn rather than loaded.
    function iconFor(type as Complications.Type?) as Icon? {
        if (type == Complications.COMPLICATION_TYPE_CURRENT_WEATHER) {
            return new WindArrow();
        }

        var resourceId = bitmapOf(type);

        return (resourceId != null) ? new Icon(resourceId) : null;
    }

    function bitmapOf(type as Complications.Type?) as ResourceId? {
        if (type == null) {
            return null;
        }

        switch (type) {
            case Complications.COMPLICATION_TYPE_BATTERY:              return Rez.Drawables.FieldBattery;
            case Complications.COMPLICATION_TYPE_STEPS:                return Rez.Drawables.FieldSteps;
            case Complications.COMPLICATION_TYPE_CALORIES:             return Rez.Drawables.FieldCalories;
            case Complications.COMPLICATION_TYPE_INTENSITY_MINUTES:    return Rez.Drawables.FieldTimer;
            case Complications.COMPLICATION_TYPE_SUNRISE:              return Rez.Drawables.Sunrise;
            case Complications.COMPLICATION_TYPE_SUNSET:               return Rez.Drawables.Sunset;
            case Complications.COMPLICATION_TYPE_ALTITUDE:             return Rez.Drawables.FieldAltitude;
            case Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT:   return Rez.Drawables.FieldNotifications;
            case Complications.COMPLICATION_TYPE_HEART_RATE:           return Rez.Drawables.FieldHeart;
            case Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE:  return Rez.Drawables.FieldRun;
            case Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE: return Rez.Drawables.FieldBike;
            case Complications.COMPLICATION_TYPE_RECOVERY_TIME:        return Rez.Drawables.FieldRecovery;
            case Complications.COMPLICATION_TYPE_BODY_BATTERY:         return Rez.Drawables.FieldHuman;
            case Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE:  return Rez.Drawables.FieldThermometer;
            case Complications.COMPLICATION_TYPE_HIGH_LOW_TEMPERATURE: return Rez.Drawables.FieldThermometer;
        }

        // The dates, COMPLICATION_TYPE_INVALID, and anything a later system
        // adds
        return null;
    }
}

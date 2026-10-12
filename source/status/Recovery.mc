import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

//! Sky blue past a day, amber past two, orange past three
class Recovery extends Icon {

    private const DAY_MINUTES = 1440;
    private const TWO_DAYS_MINUTES = 2880;
    private const THREE_DAYS_MINUTES = 4320;

    private var recoveryId as Complications.Id;

    private var minutes as Number = 0;

    private var minuteGate as MinuteGate;

    function initialize() {
        Icon.initialize(Rez.Drawables.Recovery);
        recoveryId = new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
        minuteGate = new MinuteGate();
    }

    function isReporting(settings as System.DeviceSettings) as Boolean {
        if (minuteGate.opens()) {
            var value = ComplicationReader.valueOf(recoveryId);

            minutes = (value != null) ? ValueFormat.wholeNumber(value) : 0;
        }

        return minutes > 0;
    }

    protected function tint() as Number {
        return tintFor(minutes, Icon.tint());
    }

    function tintFor(remaining as Number, plainColor as Number) as Number {
        if (remaining > THREE_DAYS_MINUTES) {
            return DayColors.TWILIGHT;
        }

        if (remaining > TWO_DAYS_MINUTES) {
            return DayColors.DAY;
        }

        if (remaining > DAY_MINUTES) {
            return DayColors.NIGHT;
        }

        return plainColor;
    }
}

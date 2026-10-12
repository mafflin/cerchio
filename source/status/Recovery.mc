import Toybox.Complications;
import Toybox.Lang;
import Toybox.System;

//! Amber past a day, orange past two
class Recovery extends Icon {

    private const MODERATE_LIMIT_MINUTES = 1440;
    private const LONG_LIMIT_MINUTES = 2880;

    private const MODERATE_COLOR = Palette.AMBER;
    private const LONG_COLOR = Palette.ORANGE;

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
        if (remaining > LONG_LIMIT_MINUTES) {
            return LONG_COLOR;
        }

        if (remaining > MODERATE_LIMIT_MINUTES) {
            return MODERATE_COLOR;
        }

        return plainColor;
    }
}

import Toybox.Complications;
import Toybox.Lang;

//! Recovery time off its complication, in whole hours, read once a minute
class RecoveryReading {

    private var complicationId as Complications.Id;
    private var wholeHours as Number = 0;
    private var minuteGate as MinuteGate;

    function initialize() {
        complicationId = new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
        minuteGate = new MinuteGate();
    }

    //! Once per full update
    function refresh() as Void {
        if (!minuteGate.opens()) {
            return;
        }

        wholeHours = 0;

        // Some watches throw on a complication they do not carry.
        try {
            var value = Complications.getComplication(complicationId).value;

            if (value != null) {
                wholeHours = ComplicationFormat.wholeHours(ComplicationFormat.wholeNumber(value));
            }
        } catch (exception) {
        }
    }

    //! 0 when recovered or unknown
    function hours() as Number {
        return wholeHours;
    }
}

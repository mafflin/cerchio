import Toybox.Application.WatchFaceConfig;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Applies the native watch face editor's settings.
class Editor {

    private const DEFAULT_COLOR = Graphics.COLOR_WHITE;

    private var fields as DataFields;

    private var currentAccent as Number = DEFAULT_COLOR;
    private var currentData as Number = DEFAULT_COLOR;

    //! Slot the editor pulses, or null
    private var pulsed as Number? = null;

    function initialize(fields as DataFields) {
        self.fields = fields;
    }

    //! Hour hand, seconds and goal dot
    function accentColor() as Number {
        return currentAccent;
    }

    //! Time, status row and data fields
    function dataColor() as Number {
        return currentData;
    }

    function pulsedSlot() as Number? {
        return pulsed;
    }

    function apply(config as WatchFaceConfig.Settings, editedType as WatchFaceConfigType?) as Void {
        currentAccent = colorOf(config.accentColor);
        currentData = colorOf(config.complicationColor);
        applyComplications(config.complicationSettings);

        if (editedType != WatchUi.WATCH_FACE_CONFIG_TYPE_COMPLICATION) {
            pulsed = null;
        }
    }

    function pulse(complication as ComplicationRef) as ComplicationDrawableRef? {
        var field = fields.fieldFor(complication.uniqueIdentifier);

        if (field == null) {
            return null;
        }

        pulsed = field.getSlotId();

        return new WatchUi.ComplicationDrawableRef({
            :drawable => field,
            :boundingBox => field.getBoundingBox()
        });
    }

    private function colorOf(chosen as WatchFaceConfig.Color?) as Number {
        if ((chosen != null) && (chosen.color != null)) {
            return chosen.color as Number;
        }

        return DEFAULT_COLOR;
    }

    private function applyComplications(slots as Array<WatchFaceConfig.ComplicationRef>?) as Void {
        if (slots == null) {
            return;
        }

        for (var i = 0; i < slots.size(); i++) {
            applySlot(slots[i]);
        }
    }

    private function applySlot(slot as WatchFaceConfig.ComplicationRef) as Void {
        var complicationId = slot.complicationId;
        var field = fields.fieldFor(slot.uniqueIdentifier);

        if (field == null) {
            return;
        }

        if (complicationId != null) {
            field.setComplicationId(complicationId);
        }

        field.refresh();
    }
}

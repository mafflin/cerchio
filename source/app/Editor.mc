import Toybox.Application.WatchFaceConfig;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The native watch face editor's side of the face: applies its settings,
//! and answers what to pulse and what was tapped.
class Editor {

    //! Until the editor picks one
    private const DEFAULT_COLOR = Graphics.COLOR_WHITE;

    private var field as ComplicationField;
    private var goalProgress as GoalProgress;

    private var currentStyle as Number = Styles.DEFAULT;
    private var currentAccent as Number = DEFAULT_COLOR;
    private var currentData as Number = DEFAULT_COLOR;

    //! The status slot's pick: notifications, or the wind
    private var notificationsPicked as Boolean = false;

    //! While the editor pulses the field, it draws the field itself
    private var pulsing as Boolean = false;

    function initialize(field as ComplicationField, goalProgress as GoalProgress) {
        self.field = field;
        self.goalProgress = goalProgress;
    }

    function style() as Number {
        return currentStyle;
    }

    //! The seconds hand and the goal numeral
    function accentColor() as Number {
        return currentAccent;
    }

    //! The time, the status row, the data field, and the rim numerals until
    //! the sun is known
    function dataColor() as Number {
        return currentData;
    }

    function isPulsing() as Boolean {
        return pulsing;
    }

    function showsNotifications() as Boolean {
        return notificationsPicked;
    }

    //! editedType is null while initializing
    function apply(config as WatchFaceConfig.Settings, editedType as WatchFaceConfigType?) as Void {
        currentStyle = styleOf(config.styleId);
        currentAccent = colorOf(config.accentColor);
        currentData = colorOf(config.complicationColor);
        applyComplications(config.complicationSettings);

        // On to another setting: the field is no longer being pulsed.
        if (editedType != WatchUi.WATCH_FACE_CONFIG_TYPE_COMPLICATION) {
            pulsing = false;
        }
    }

    //! The drawable to pulse; null for the goal and the status slot, which
    //! have none
    function pulse(complication as ComplicationRef) as ComplicationDrawableRef? {
        if (complication.uniqueIdentifier != SlotId.CENTER) {
            return null;
        }

        pulsing = true;

        return new WatchUi.ComplicationDrawableRef({
            :drawable => field,
            :boundingBox => field.getBoundingBox()
        });
    }

    //! The slot under a tap, or null
    function tappedSlot(x as Number, y as Number) as Number? {
        return field.containsPoint(x, y) ? field.getSlotId() : null;
    }

    private function styleOf(styleId as Number?) as Number {
        if (styleId == null) {
            return Styles.DEFAULT;
        }

        return styleId;
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

    //! null until picked: the default type stands
    private function applySlot(slot as WatchFaceConfig.ComplicationRef) as Void {
        var complicationId = slot.complicationId;

        if (slot.uniqueIdentifier == SlotId.STATUS) {
            if (complicationId != null) {
                notificationsPicked = (complicationId.getType() == Complications.COMPLICATION_TYPE_NOTIFICATION_COUNT);
            }

            return;
        }

        if (slot.uniqueIdentifier == SlotId.GOAL) {
            if (complicationId != null) {
                goalProgress.setType(complicationId.getType());
            }

            return;
        }

        if (slot.uniqueIdentifier != SlotId.CENTER) {
            return;
        }

        if (complicationId != null) {
            field.setComplicationId(complicationId);
        }

        field.refresh();
    }
}

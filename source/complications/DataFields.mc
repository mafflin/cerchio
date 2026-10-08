import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;

//! The data fields below the time, left to right, the middle one centered:
//! where they go, what they show, and the live updates that follow it.
class DataFields {

    private var fields as Array<ComplicationField>;

    function initialize() {
        fields = [
            new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS),
            new ComplicationField(SlotId.CENTER, Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY),
            new ComplicationField(SlotId.RIGHT, Complications.COMPLICATION_TYPE_BODY_BATTERY)
        ] as Array<ComplicationField>;
    }

    //! Once per layout, side by side from top
    function prepare(dc as Dc, top as Number) as Void {
        var width = fields[0].widthIn(dc);
        var middle = fields.size() / 2;
        var centerY = top + (heightIn(dc) / 2);

        for (var i = 0; i < fields.size(); i++) {
            fields[i].prepare(dc, Dial.centerX + ((i - middle) * width), centerY);
        }
    }

    function heightIn(dc as Dc) as Number {
        return fields[0].heightIn(dc);
    }

    function setColor(color as Number) as Void {
        for (var i = 0; i < fields.size(); i++) {
            fields[i].setColor(color);
        }
    }

    //! All but the one in skippedSlot, which the editor draws while it pulses
    //! it; null for none
    function draw(dc as Dc, skippedSlot as Number?) as Void {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].getSlotId() != skippedSlot) {
                fields[i].draw(dc);
            }
        }
    }

    //! The field in a slot, null for any other slot
    function fieldFor(slotId as Number?) as ComplicationField? {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].getSlotId() == slotId) {
                return fields[i];
            }
        }

        return null;
    }

    //! The slot under a point, or null
    function slotAt(x as Number, y as Number) as Number? {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].containsPoint(x, y)) {
                return fields[i].getSlotId();
            }
        }

        return null;
    }

    //! What each field shows, in order
    function shownIds() as Array<Complications.Id> {
        var ids = new [fields.size()] as Array<Complications.Id>;

        for (var i = 0; i < fields.size(); i++) {
            ids[i] = fields[i].getComplicationId();
        }

        return ids;
    }

    //! Whether any field changed
    function refreshShowing(complicationId as Complications.Id) as Boolean {
        var changed = false;

        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].shows(complicationId)) {
                fields[i].refresh();
                changed = true;
            }
        }

        return changed;
    }

    function subscribe() as Void {
        for (var i = 0; i < fields.size(); i++) {
            Complications.subscribeToUpdates(fields[i].getComplicationId());
        }
    }

    //! Live updates follow the picks, previous being shownIds() before them.
    //! A pick another field still shows keeps its updates.
    function follow(previous as Array<Complications.Id>) as Void {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].shows(previous[i])) {
                continue;
            }

            if (!isShown(previous[i])) {
                Complications.unsubscribeFromUpdates(previous[i]);
            }

            Complications.subscribeToUpdates(fields[i].getComplicationId());
        }
    }

    private function isShown(complicationId as Complications.Id) as Boolean {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].shows(complicationId)) {
                return true;
            }
        }

        return false;
    }
}

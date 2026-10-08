import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;

//! The data fields below the time, in rows centered on the middle: where
//! they go, what they show, and the live updates that follow it. The second
//! row shows only in the style that has it, but keeps its picks and their
//! updates all the same.
class DataFields {

    //! How many fields the first row holds; the rest are the second
    private const FIRST_ROW = 3;

    private var fields as Array<ComplicationField>;

    //! The first row, or both
    private var shownCount as Number = FIRST_ROW;

    function initialize() {
        fields = [
            new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS),
            new ComplicationField(SlotId.CENTER, Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY),
            new ComplicationField(SlotId.RIGHT, Complications.COMPLICATION_TYPE_BODY_BATTERY),
            new ComplicationField(SlotId.LOWER_LEFT, Complications.COMPLICATION_TYPE_SUNRISE),
            new ComplicationField(SlotId.LOWER_RIGHT, Complications.COMPLICATION_TYPE_SUNSET)
        ] as Array<ComplicationField>;
    }

    //! Once per layout: the first row from top, the second from secondTop
    function prepare(dc as Dc, top as Number, secondTop as Number) as Void {
        var halfHeight = heightIn(dc) / 2;

        placeRow(dc, 0, FIRST_ROW, top + halfHeight);
        placeRow(dc, FIRST_ROW, fields.size(), secondTop + halfHeight);
    }

    function setSecondRowShown(shown as Boolean) as Void {
        shownCount = shown ? fields.size() : FIRST_ROW;
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
        for (var i = 0; i < shownCount; i++) {
            if (fields[i].getSlotId() != skippedSlot) {
                fields[i].draw(dc);
            }
        }
    }

    //! The field in a slot, null for any other slot
    function fieldFor(slotId as Number?) as ComplicationField? {
        var index = indexOf(slotId);

        return (index != null) ? fields[index] : null;
    }

    //! As fieldFor(), but null for a field the style does not show
    function shownFieldFor(slotId as Number?) as ComplicationField? {
        var index = indexOf(slotId);

        return ((index != null) && (index < shownCount)) ? fields[index] : null;
    }

    //! The shown slot under a point, or null
    function slotAt(x as Number, y as Number) as Number? {
        for (var i = 0; i < shownCount; i++) {
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

    //! Centers a field's width apart, the row centered whatever its count
    private function placeRow(dc as Dc, from as Number, to as Number, centerY as Number) as Void {
        var width = fields[0].widthIn(dc);
        var count = to - from;

        for (var i = 0; i < count; i++) {
            fields[from + i].prepare(dc, Dial.centerX + ((((2 * i) - (count - 1)) * width) / 2), centerY);
        }
    }

    private function indexOf(slotId as Number?) as Number? {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].getSlotId() == slotId) {
                return i;
            }
        }

        return null;
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

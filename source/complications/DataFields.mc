import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;

//! The data fields below the time, a pair either side of the middle: where
//! they go, what they show, and the live updates that follow it.
class DataFields {

    //! Between the two fields' centers, as a share of the screen width: more
    //! than a field's width, so the pair leaves air between them
    private const SPACING_RATIO = 0.28;

    private var fields as Array<ComplicationField>;

    function initialize() {
        fields = [
            new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS),
            new ComplicationField(SlotId.RIGHT, Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY)
        ] as Array<ComplicationField>;
    }

    //! Once per layout: the row from top
    function prepare(dc as Dc, top as Number) as Void {
        var centerY = top + (fields[0].heightIn(dc) / 2);
        var spacing = (dc.getWidth() * SPACING_RATIO).toNumber();
        var count = fields.size();

        for (var i = 0; i < count; i++) {
            fields[i].prepare(dc, Dial.centerX + ((((2 * i) - (count - 1)) * spacing) / 2), centerY);
        }
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
        var index = indexOf(slotId);

        return (index != null) ? fields[index] : null;
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

    //! Once a minute: the fields whose value moves with the time
    function refreshClocked() as Void {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].followsClock()) {
                fields[i].refresh();
            }
        }
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

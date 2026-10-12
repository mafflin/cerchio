import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;

//! The fields below the time, centered as one row
class DataFields {

    private const GAP_RATIO = 0.03;

    private var fields as Array<ComplicationField>;

    private var gap as Number = 0;

    //! [left, top, right, bottom] of the last draw
    private var drawnBox as Array<Number>? = null;

    function initialize() {
        fields = [
            new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS),
            new ComplicationField(SlotId.RIGHT, Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY)
        ] as Array<ComplicationField>;
    }

    function prepare(dc as Dc, top as Number) as Void {
        var centerY = top + (IconText.heightIn(dc) / 2);

        gap = (Dial.screenWidth * GAP_RATIO).toNumber();

        for (var i = 0; i < fields.size(); i++) {
            fields[i].prepare(dc, centerY);
        }
    }

    function setColor(color as Number) as Void {
        for (var i = 0; i < fields.size(); i++) {
            fields[i].setColor(color);
        }
    }

    //! skippedSlot: the one the editor pulses
    function draw(dc as Dc, skippedSlot as Number?) as Void {
        placeContents(dc);
        drawPlaced(dc, skippedSlot);
        drawnBox = contentBox();
    }

    //! Only the row, over the drawn face; nothing else may overlap its box.
    //! Returns the changed box.
    function redraw(dc as Dc, skippedSlot as Number?) as Array<Number>? {
        placeContents(dc);

        var box = union(drawnBox, contentBox());

        if (box == null) {
            return null;
        }

        dc.setClip(box[0], box[1], box[2] - box[0], box[3] - box[1]);
        dc.setColor(Palette.BACKGROUND, Palette.BACKGROUND);
        dc.fillRectangle(box[0], box[1], box[2] - box[0], box[3] - box[1]);
        drawPlaced(dc, skippedSlot);
        dc.clearClip();

        drawnBox = contentBox();

        return box;
    }

    function fieldFor(slotId as Number?) as ComplicationField? {
        var index = indexOf(slotId);

        return (index != null) ? fields[index] : null;
    }

    function slotAt(x as Number, y as Number) as Number? {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].containsPoint(x, y)) {
                return fields[i].getSlotId();
            }
        }

        return null;
    }

    function shownIds() as Array<Complications.Id> {
        var ids = new [fields.size()] as Array<Complications.Id>;

        for (var i = 0; i < fields.size(); i++) {
            ids[i] = fields[i].getComplicationId();
        }

        return ids;
    }

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

    function refreshClocked() as Void {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].followsClock()) {
                fields[i].refresh();
            }
        }
    }

    function refreshAll() as Void {
        for (var i = 0; i < fields.size(); i++) {
            fields[i].refresh();
        }
    }

    function subscribe() as Void {
        for (var i = 0; i < fields.size(); i++) {
            Complications.subscribeToUpdates(fields[i].getComplicationId());
        }
    }

    //! previous: shownIds() before the pick
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

    private function placeContents(dc as Dc) as Void {
        var count = fields.size();
        var widths = new [count] as Array<Number>;
        var total = 0;
        var shown = 0;

        for (var i = 0; i < count; i++) {
            widths[i] = fields[i].contentWidth(dc);

            if (widths[i] > 0) {
                total += widths[i];
                shown++;
            }
        }

        if (shown > 1) {
            total += gap * (shown - 1);
        }

        var left = Dial.centerX - (total / 2);

        for (var i = 0; i < count; i++) {
            fields[i].placeContent(left, widths[i]);

            if (widths[i] > 0) {
                left += widths[i] + gap;
            }
        }
    }

    private function drawPlaced(dc as Dc, skippedSlot as Number?) as Void {
        for (var i = 0; i < fields.size(); i++) {
            if (fields[i].getSlotId() != skippedSlot) {
                fields[i].draw(dc);
            }
        }
    }

    private function contentBox() as Array<Number>? {
        var box = null as Array<Number>?;

        for (var i = 0; i < fields.size(); i++) {
            box = union(box, fields[i].contentBox());
        }

        return box;
    }

    private function union(first as Array<Number>?, second as Array<Number>?) as Array<Number>? {
        if (first == null) {
            return second;
        }

        if (second == null) {
            return first;
        }

        return [
            Numbers.min(first[0], second[0]),
            Numbers.min(first[1], second[1]),
            Numbers.max(first[2], second[2]),
            Numbers.max(first[3], second[3])
        ];
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

import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

//! The row as the view lays it out, with whatever the simulator reports
//! for its default fields, steps and the date. An empty field is made by
//! pointing it at a complication no watch has.
(:test)
module DataFieldsTest {

    //! Between the two contents: the gap, less the padding either box keeps
    const GAP_RATIO = 0.03;
    const PADDING = 2;

    //! Side by side, a gap between, centered as one
    (:test)
    function centeredAsOne(logger as Test.Logger) as Boolean {
        var sizes = Probe.screenSizes();

        for (var i = 0; i < sizes.size(); i++) {
            var size = sizes[i];
            var bitmap = Probe.screen(size);
            var fields = drawnRow(bitmap);
            var left = boxOf(fields, SlotId.LEFT);
            var right = boxOf(fields, SlotId.RIGHT);

            if ((left == null) || (right == null)) {
                logger.warning(size + "px: a field shows nothing, set steps and the date in the simulator");
                continue;
            }

            var gap = (size * GAP_RATIO).toNumber();

            logger.debug(size + "px: left " + left + ", right " + right);
            Approx.check(((left[0] + right[2]) - (2 * Dial.centerX)).abs() <= 1, size + "px centered as one");
            Approx.checkEqual(right[0] - left[2], gap - (2 * PADDING), size + "px gap between");
        }

        return true;
    }

    //! A field with nothing takes no room and no gap: the other is centered
    //! alone
    (:test)
    function emptyFieldTakesNoGap(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var fields = drawnRow(bitmap);

        empty(fields, SlotId.RIGHT);
        fields.draw(bitmap.getDc(), null);

        var left = boxOf(fields, SlotId.LEFT);

        Approx.check(boxOf(fields, SlotId.RIGHT) == null, "the empty field covers nothing");

        if (left == null) {
            logger.warning("the left field shows nothing, set steps in the simulator");

            return true;
        }

        Approx.check(((left[0] + left[2]) - (2 * Dial.centerX)).abs() <= 1, "the other centered alone");

        return true;
    }

    //! What redraw() paints over: the old row and the new, or nothing
    (:test)
    function redrawBox(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var dc = bitmap.getDc();
        var fields = drawnRow(bitmap);
        var before = boxOf(fields, SlotId.RIGHT);
        var unchanged = fields.redraw(dc, null);

        logger.debug("right before " + before + ", unchanged redraw " + unchanged);

        if (before != null) {
            Approx.check(unchanged != null, "the row again");

            empty(fields, SlotId.RIGHT);

            var shrunk = fields.redraw(dc, null);

            Approx.check(shrunk != null, "the row shrunk");

            if (shrunk != null) {
                Approx.check(shrunk[2] >= before[2], "over where the emptied field was");
            }
        }

        empty(fields, SlotId.LEFT);
        empty(fields, SlotId.RIGHT);
        fields.draw(dc, null);
        Approx.check(fields.redraw(dc, null) == null, "nothing to paint over");

        return true;
    }

    //! A tap on a field's target finds its slot
    (:test)
    function slots(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var fields = drawnRow(bitmap);

        checkTapped(fields, SlotId.LEFT);
        checkTapped(fields, SlotId.RIGHT);
        Approx.check(fields.slotAt(0, 0) == null, "the corner");
        Approx.check(fields.fieldFor(99) == null, "no such slot");

        return true;
    }

    (:debug)
    function drawnRow(bitmap as Graphics.BufferedBitmap) as DataFields {
        var dc = bitmap.getDc();
        var fields = new DataFields();

        fields.prepare(dc, Probe.fieldsTop());
        fields.refreshAll();
        fields.draw(dc, null);

        return fields;
    }

    (:debug)
    function boxOf(fields as DataFields, slot as Number) as Array<Number>? {
        return (fields.fieldFor(slot) as ComplicationField).contentBox();
    }

    (:debug)
    function empty(fields as DataFields, slot as Number) as Void {
        var field = fields.fieldFor(slot) as ComplicationField;

        field.setComplicationId(new Complications.Id(Complications.COMPLICATION_TYPE_INVALID));
        field.refresh();
    }

    (:debug)
    function checkTapped(fields as DataFields, slot as Number) as Void {
        var field = fields.fieldFor(slot) as ComplicationField;
        var x = field.locX.toNumber() + (field.width.toNumber() / 2);
        var y = field.locY.toNumber() + (field.height.toNumber() / 2);

        Approx.checkEqual(fields.slotAt(x, y) as Number, slot, "slot " + slot);
    }
}

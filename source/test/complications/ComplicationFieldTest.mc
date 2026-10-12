import Toybox.Complications;
import Toybox.Lang;
import Toybox.Test;

(:test)
module ComplicationFieldTest {

    (:test)
    function prepared(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var dc = bitmap.getDc();
        var field = new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS);

        field.prepare(dc, 150);

        Approx.checkEqual(field.width.toNumber(), (Probe.SMALL_SCREEN * 0.25).toNumber(), "a quarter of the screen");
        Approx.checkEqual(field.height.toNumber(), dc.getFontHeight(IconText.FONT), "a line high");
        Approx.check(field.contentBox() == null, "nothing placed yet");

        return true;
    }

    (:test)
    function placed(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var field = new ComplicationField(SlotId.LEFT, Complications.COMPLICATION_TYPE_STEPS);

        field.prepare(bitmap.getDc(), 150);
        field.placeContent(50, 40);

        var targetMiddle = field.locX.toNumber() + (field.width.toNumber() / 2);
        var box = field.contentBox();

        Approx.check((targetMiddle - 70).abs() <= 1, "tap target centered: " + targetMiddle);
        Approx.check(box != null, "a content box");

        if (box != null) {
            Approx.checkEqual(box[0], 48, "content's left, padded");
            Approx.checkEqual(box[2], 92, "content's right, padded");
        }

        Approx.check(field.containsPoint(70, 150), "the middle is a hit");
        Approx.check(!field.containsPoint(0, 0), "the corner is not");

        return true;
    }
}

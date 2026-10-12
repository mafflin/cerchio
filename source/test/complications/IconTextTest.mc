import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

(:test)
module IconTextTest {

    (:test)
    function span(logger as Test.Logger) as Boolean {
        var icon = new Icon(Rez.Drawables.FieldSteps);
        var width = icon.width();

        Approx.checkEqual(IconText.iconSpan(null, "12"), 0, "no icon");
        Approx.checkEqual(IconText.iconSpan(icon, "12"), width + (width / IconText.GAP_DIVISOR), "icon and digits");
        Approx.checkEqual(IconText.iconSpan(icon, ""), width, "icon alone");

        return true;
    }

    (:test)
    function width(logger as Test.Logger) as Boolean {
        var bitmap = Probe.screen(Probe.SMALL_SCREEN);
        var dc = bitmap.getDc();
        var icon = new Icon(Rez.Drawables.FieldSteps);
        var digits = dc.getTextWidthInPixels("12", IconText.FONT);

        Approx.checkEqual(IconText.widthOf(dc, null, ""), 0, "nothing");
        Approx.checkEqual(IconText.widthOf(dc, icon, ""), icon.width(), "icon alone");
        Approx.checkEqual(IconText.widthOf(dc, null, "12"), digits, "digits alone");
        Approx.checkEqual(IconText.widthOf(dc, icon, "12"), IconText.iconSpan(icon, "12") + digits, "both");

        return true;
    }

    (:test)
    function iconOnDigits(logger as Test.Logger) as Boolean {
        var icon = new Icon(Rez.Drawables.FieldSteps);
        var top = 100;
        var ascent = Graphics.getFontAscent(IconText.FONT);
        var digitsMiddle = top + ascent - (Numbers.round(ascent * IconText.DIGIT_SHARE) / 2);
        var iconMiddle = IconText.iconTop(top, icon) + (icon.height() / 2);

        logger.debug("digits' middle " + digitsMiddle + ", icon's " + iconMiddle);
        Approx.check((iconMiddle - digitsMiddle).abs() <= 1, "centered on the digits");

        return true;
    }
}

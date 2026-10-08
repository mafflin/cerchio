import Toybox.Graphics;
import Toybox.Lang;

//! An icon and the digits beside it, centered together on a line, in the
//! icon's tint: a data field. Either may be missing.
module IconText {

    const FONT = Graphics.FONT_XTINY;

    //! The digits' share of the font's ascent, the rest being air above them.
    //! Measured off a 280px screenshot: 14px digits.
    const DIGIT_SHARE = 0.85;

    //! Air between the icon and the digits, as a share of the icon's width
    const GAP_DIVISOR = 8;

    function heightIn(dc as Dc) as Number {
        return dc.getFontHeight(FONT);
    }

    //! top is the top of the digits' font box; the icon is centered on the
    //! digits, which sit at the bottom of the ascent
    function draw(dc as Dc, centerX as Number, top as Number, icon as Icon?, text as String, color as Number) as Void {
        var hasText = text.length() > 0;
        var iconWidth = 0;
        var gap = 0;

        if (icon != null) {
            iconWidth = icon.width();
            gap = hasText ? (iconWidth / GAP_DIVISOR) : 0;
        }

        var textWidth = hasText ? dc.getTextWidthInPixels(text, FONT) : 0;
        var left = centerX - ((iconWidth + gap + textWidth) / 2);

        if (icon != null) {
            var ascent = Fonts.ascentOf(FONT);
            var digitHeight = Dial.pixel(ascent * DIGIT_SHARE);

            icon.setTint(color);
            icon.draw(dc, left, top + ascent - ((digitHeight + icon.height()) / 2));
        }

        if (hasText) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(left + iconWidth + gap, top, FONT, text, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }
}

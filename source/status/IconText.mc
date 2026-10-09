import Toybox.Graphics;
import Toybox.Lang;

//! An icon and the digits beside it, together on a line, in the icon's
//! tint: a data field. Either may be missing.
module IconText {

    const FONT = Graphics.FONT_TINY;

    //! The digits' share of the font's ascent, the rest being air above them.
    //! Set by eye off a 260px screenshot: 18px digits.
    const DIGIT_SHARE = 0.80;

    //! Air between the icon and the digits, as a share of the icon's width
    const GAP_DIVISOR = 8;

    function heightIn(dc as Dc) as Number {
        return dc.getFontHeight(FONT);
    }

    //! The icon and digits as one group, its left edge, middle or right edge
    //! at x by justify. top is the top of the digits' font box; the icon is
    //! centered on the digits, which sit at the bottom of the ascent.
    function draw(dc as Dc, x as Number, justify as Graphics.TextJustification, top as Number, icon as Icon?, text as String, color as Number) as Void {
        var hasText = text.length() > 0;
        var iconWidth = 0;
        var gap = 0;

        if (icon != null) {
            iconWidth = icon.width();
            gap = hasText ? (iconWidth / GAP_DIVISOR) : 0;
        }

        var textWidth = hasText ? dc.getTextWidthInPixels(text, FONT) : 0;
        var left = leftOf(x, justify, iconWidth + gap + textWidth);

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

    //! The group's left edge
    function leftOf(x as Number, justify as Graphics.TextJustification, width as Number) as Number {
        if (justify == Graphics.TEXT_JUSTIFY_RIGHT) {
            return x - width;
        }

        if (justify == Graphics.TEXT_JUSTIFY_CENTER) {
            return x - (width / 2);
        }

        return x;
    }
}

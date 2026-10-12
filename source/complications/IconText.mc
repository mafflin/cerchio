import Toybox.Graphics;
import Toybox.Lang;

//! Icon and text on a line; either may be missing
module IconText {

    const FONT = Graphics.FONT_TINY;

    //! Digits' share of the font ascent, by eye
    const DIGIT_SHARE = 0.80;

    const GAP_DIVISOR = 8;

    function heightIn(dc as Dc) as Number {
        return dc.getFontHeight(FONT);
    }

    function widthOf(dc as Dc, icon as Icon?, text as String) as Number {
        var textWidth = (text.length() > 0) ? dc.getTextWidthInPixels(text, FONT) : 0;

        return iconSpan(icon, text) + textWidth;
    }

    //! top: of the font box; the icon centers on the digits
    function draw(dc as Dc, left as Number, top as Number, icon as Icon?, text as String, color as Number, iconColor as Number) as Void {
        if (icon != null) {
            icon.setTint(iconColor);
            icon.draw(dc, left, iconTop(top, icon));
        }

        if (text.length() > 0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(left + iconSpan(icon, text), top, FONT, text, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function iconTop(top as Number, icon as Icon) as Number {
        var ascent = Graphics.getFontAscent(FONT);
        var digitHeight = Numbers.round(ascent * DIGIT_SHARE);

        return top + ascent - ((digitHeight + icon.height()) / 2);
    }

    function iconSpan(icon as Icon?, text as String) as Number {
        if (icon == null) {
            return 0;
        }

        var iconWidth = icon.width();

        return (text.length() > 0) ? (iconWidth + (iconWidth / GAP_DIVISOR)) : iconWidth;
    }
}

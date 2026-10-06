import Toybox.Graphics;
import Toybox.Lang;

module Fonts {

    //! Roboto's digits stand this share of its ascent; the rest is air above
    const DIGIT_SHARE = 0.77;

    //! From the top of the font box to the baseline
    function ascentOf(dc as Dc, font as FontType) as Number {
        if (Graphics has :getFontAscent) {
            return Graphics.getFontAscent(font);
        }

        return dc.getFontHeight(font);
    }

    //! The height of the digits' ink: no air above, no descent below
    function digitHeightOf(dc as Dc, font as FontType) as Number {
        return Dial.pixel(ascentOf(dc, font) * DIGIT_SHARE);
    }
}

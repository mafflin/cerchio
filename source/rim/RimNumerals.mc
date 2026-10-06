import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! 01 through 24 against the edge of the glass, 24 at the bottom. Turned to
//! face the middle, the bottom half flipped so it does not read upside down;
//! a watch without vector fonts gets them upright.
class RimNumerals {

    private const COUNT = Dial.HOURS;
    private const FORMAT = "%02d";

    //! Air between the glass and the digits, as a share of the radius
    private const GAP_DIVISOR = 32;

    //! The system font the vector one is sized off, and falls back to
    private const SYSTEM_FONT = Graphics.FONT_XTINY;

    //! The vector font a touch smaller than the system one
    private const SIZE_NUMERATOR = 4;
    private const SIZE_DIVISOR = 5;

    //! In order: the first the watch carries is used
    private const FACES = ["RobotoCondensedBold", "RobotoCondensedRegular", "RobotoRegular", "Swiss721Regular"];

    private const JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private var font as FontType = SYSTEM_FONT;
    private var isTurned as Boolean = false;
    private var color as Number = Graphics.COLOR_WHITE;

    //! Resolved in prepare(): how far the digits may reach, how tall they
    //! are, and how far the font box center sits below the digits' center
    private var outerEdge as Number = 0;
    private var inkHeight as Number = 0;
    private var descentShift as Float = 0.0;

    //! The nearest the digits come to the middle, from the center
    private var innerEdge as Number = 0;

    //! Per numeral, resolved in prepare()
    private var texts as Array<String>;
    private var xs as Array<Number>;
    private var ys as Array<Number>;
    private var angles as Array<Number>;

    function initialize() {
        texts = new [COUNT] as Array<String>;
        xs = new [COUNT] as Array<Number>;
        ys = new [COUNT] as Array<Number>;
        angles = new [COUNT] as Array<Number>;

        for (var index = 0; index < COUNT; index++) {
            // Midnight reads as 24, not 0.
            var hour = (index == 0) ? COUNT : index;

            texts[index] = hour.format(FORMAT);
        }
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    //! After Dial.setup()
    function prepare(dc as Dc) as Void {
        chooseFont(dc);

        outerEdge = Dial.rim - (Dial.rim / GAP_DIVISOR);
        inkHeight = Fonts.digitHeightOf(dc, font);
        descentShift = shiftOf(dc);
        innerEdge = outerEdge - inkHeight;

        for (var index = 0; index < COUNT; index++) {
            if (isTurned) {
                placeTurned(index);
            } else {
                placeUpright(dc, index);
            }
        }
    }

    function inner() as Number {
        return innerEdge;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        for (var index = 0; index < COUNT; index++) {
            if (isTurned) {
                dc.drawAngledText(xs[index], ys[index], font as VectorFont, texts[index], JUSTIFY, angles[index]);
            } else {
                dc.drawText(xs[index], ys[index], font, texts[index], JUSTIFY);
            }
        }
    }

    //! The digits reach the glass by their height. The font box's center
    //! lies toward the baseline: inward for upright numerals, outward for
    //! flipped ones.
    private function placeTurned(index as Number) as Void {
        var degrees = Dial.positionOfHour(index);
        var flipped = isUpsideDown(degrees);
        var middle = outerEdge - (inkHeight / 2.0);
        var radius = flipped ? (middle + descentShift) : (middle - descentShift);
        var radians = Dial.radiansOf(degrees);

        xs[index] = Dial.pointX(radians, radius);
        ys[index] = Dial.pointY(radians, radius);
        angles[index] = angleOf(degrees, flipped);
    }

    //! Upright, the digits reach the glass by their width at the sides and
    //! their height at the top and bottom
    private function placeUpright(dc as Dc, index as Number) as Void {
        var radians = Dial.radiansOf(Dial.positionOfHour(index));
        var halfWidth = dc.getTextWidthInPixels(texts[index], font) / 2.0;
        var reach = (halfWidth * Math.cos(radians).abs()) + ((inkHeight / 2.0) * Math.sin(radians).abs());
        var radius = outerEdge - reach;

        innerEdge = min(innerEdge, Dial.pixel(radius - reach));

        xs[index] = Dial.pointX(radians, radius);
        ys[index] = Dial.pointY(radians, radius) + Dial.pixel(descentShift);
        angles[index] = 0;
    }

    //! Half the descent below the digits, less half the air above them
    private function shiftOf(dc as Dc) as Float {
        var ascent = Fonts.ascentOf(dc, font);
        var descent = dc.getFontHeight(font) - ascent;
        var air = ascent - inkHeight;

        return (descent - air) / 2.0;
    }

    private function min(first as Number, second as Number) as Number {
        return (first < second) ? first : second;
    }

    //! The bottom of the glass, past a quarter turn either side of the top
    private function isUpsideDown(degrees as Number) as Boolean {
        return (degrees > Dial.QUARTER_TURN) && (degrees < (Dial.DEGREES_PER_CIRCLE - Dial.QUARTER_TURN));
    }

    //! Counterclockwise, the way drawAngledText turns; flipped ones half a
    //! turn more
    private function angleOf(degrees as Number, flipped as Boolean) as Number {
        var angle = Dial.DEGREES_PER_CIRCLE - degrees;

        if (flipped) {
            angle += Dial.HALF_TURN;
        }

        return angle % Dial.DEGREES_PER_CIRCLE;
    }

    //! A vector font if the watch can turn text, the system font otherwise
    private function chooseFont(dc as Dc) as Void {
        font = SYSTEM_FONT;
        isTurned = false;

        if (!(Graphics has :getVectorFont) || !(dc has :drawAngledText)) {
            return;
        }

        var vectorFont = Graphics.getVectorFont({
            :face => FACES,
            :size => dc.getFontHeight(SYSTEM_FONT) * SIZE_NUMERATOR / SIZE_DIVISOR
        });

        if (vectorFont != null) {
            font = vectorFont;
            isTurned = true;
        }
    }
}

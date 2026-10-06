import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! 01 through 24 against the edge of the glass, 24 at the bottom. Turned to
//! face the middle, the bottom half flipped so it does not read upside down;
//! a watch without vector fonts gets them upright. Colored with the day, in
//! the data color until the sun is known. A highlighted numeral is a font
//! step larger in the accent color, centered on the others' line.
class RimNumerals {

    private const COUNT = Dial.HOURS;
    private const FORMAT = "%02d";

    //! Air between the glass and the digits, as a share of the radius
    private const GAP_DIVISOR = 32;

    //! The system fonts the vector ones are sized off, and fall back to
    private const SYSTEM_FONT = Graphics.FONT_XTINY;
    private const HIGHLIGHT_SYSTEM_FONT = Graphics.FONT_TINY;

    //! The vector font a touch smaller than the system one
    private const SIZE_NUMERATOR = 4;
    private const SIZE_DIVISOR = 5;

    //! In order: the first the watch carries is used
    private const FACES = ["RobotoCondensedBold", "RobotoCondensedRegular", "RobotoRegular", "Swiss721Regular"];

    private const JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private var font as FontType = SYSTEM_FONT;
    private var highlightFont as FontType = HIGHLIGHT_SYSTEM_FONT;
    private var isTurned as Boolean = false;

    //! Until the sun is known
    private var color as Number = Graphics.COLOR_WHITE;
    private var highlightColor as Number = Graphics.COLOR_WHITE;

    //! The numeral draw() picks out, null for none
    private var highlightIndex as Number? = null;

    //! Resolved in prepare(): how far the digits may reach, how tall they
    //! are, and how far the font box center sits below the digits' center
    private var outerEdge as Number = 0;
    private var inkHeight as Number = 0;
    private var descentShift as Float = 0.0;
    private var highlightInk as Number = 0;
    private var highlightShift as Float = 0.0;

    //! The nearest the digits come to the middle, from the center
    private var innerEdge as Number = 0;

    //! Per numeral, resolved in prepare(), plain and highlighted
    private var texts as Array<String>;
    private var angles as Array<Number>;
    private var xs as Array<Number>;
    private var ys as Array<Number>;
    private var highlightXs as Array<Number>;
    private var highlightYs as Array<Number>;

    private var dayColors as DayColors;

    function initialize(dayColors as DayColors) {
        self.dayColors = dayColors;
        texts = new [COUNT] as Array<String>;
        angles = new [COUNT] as Array<Number>;
        xs = new [COUNT] as Array<Number>;
        ys = new [COUNT] as Array<Number>;
        highlightXs = new [COUNT] as Array<Number>;
        highlightYs = new [COUNT] as Array<Number>;

        for (var index = 0; index < COUNT; index++) {
            // Midnight reads as 24, not 0.
            var hour = (index == 0) ? COUNT : index;

            texts[index] = hour.format(FORMAT);
        }
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function setHighlightColor(highlightColor as Number) as Void {
        self.highlightColor = highlightColor;
    }

    function setHighlightIndex(highlightIndex as Number?) as Void {
        self.highlightIndex = highlightIndex;
    }

    //! The numeral nearest a share of the way round, clockwise from the top
    function indexAt(share as Float) as Number {
        var steps = Math.round(share * COUNT).toNumber();

        return ((Dial.MIDNIGHT_DEGREES / Dial.DEGREES_PER_HOUR) + steps) % COUNT;
    }

    //! After Dial.setup()
    function prepare(dc as Dc) as Void {
        chooseFont(dc);

        outerEdge = Dial.rim - (Dial.rim / GAP_DIVISOR);
        inkHeight = Fonts.digitHeightOf(dc, font);
        descentShift = shiftOf(dc, font, inkHeight);
        highlightInk = Fonts.digitHeightOf(dc, highlightFont);
        highlightShift = shiftOf(dc, highlightFont, highlightInk);
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
        for (var index = 0; index < COUNT; index++) {
            drawNumeral(dc, index, index == highlightIndex);
        }
    }

    private function drawNumeral(dc as Dc, index as Number, isHighlight as Boolean) as Void {
        var numeralFont = isHighlight ? highlightFont : font;
        var x = isHighlight ? highlightXs[index] : xs[index];
        var y = isHighlight ? highlightYs[index] : ys[index];

        dc.setColor(isHighlight ? highlightColor : plainColorAt(index), Graphics.COLOR_TRANSPARENT);

        if (isTurned) {
            dc.drawAngledText(x, y, numeralFont as VectorFont, texts[index], JUSTIFY, angles[index]);
        } else {
            dc.drawText(x, y, numeralFont, texts[index], JUSTIFY);
        }
    }

    private function plainColorAt(index as Number) as Number {
        var dayColor = dayColors.knownColorAt(Dial.positionOfHour(index));

        if (dayColor == null) {
            return color;
        }

        return dayColor;
    }

    //! The digits reach the glass by their height, a highlight centered on
    //! the same line. The font box's center lies toward the baseline: inward
    //! for upright numerals, outward for flipped ones.
    private function placeTurned(index as Number) as Void {
        var degrees = Dial.positionOfHour(index);
        var flipped = isUpsideDown(degrees);
        var toward = flipped ? 1 : -1;
        var middle = outerEdge - (inkHeight / 2.0);
        var radius = middle + (toward * descentShift);
        var highlightRadius = middle + (toward * highlightShift);
        var radians = Dial.radiansOf(degrees);

        xs[index] = Dial.pointX(radians, radius);
        ys[index] = Dial.pointY(radians, radius);
        highlightXs[index] = Dial.pointX(radians, highlightRadius);
        highlightYs[index] = Dial.pointY(radians, highlightRadius);
        angles[index] = angleOf(degrees, flipped);
    }

    //! Upright, the digits reach the glass by their width at the sides and
    //! their height at the top and bottom. The highlight leaves the inner
    //! edge to the others, so the circle does not move for it.
    private function placeUpright(dc as Dc, index as Number) as Void {
        var radians = Dial.radiansOf(Dial.positionOfHour(index));
        var reach = uprightReach(dc, index, font, inkHeight, radians);
        var radius = outerEdge - reach;
        var highlightRadius = outerEdge - uprightReach(dc, index, highlightFont, highlightInk, radians);

        innerEdge = Numbers.min(innerEdge, Dial.pixel(radius - reach));

        xs[index] = Dial.pointX(radians, radius);
        ys[index] = Dial.pointY(radians, radius) + Dial.pixel(descentShift);
        highlightXs[index] = Dial.pointX(radians, highlightRadius);
        highlightYs[index] = Dial.pointY(radians, highlightRadius) + Dial.pixel(highlightShift);
        angles[index] = 0;
    }

    //! How far an upright numeral reaches from its center toward the glass
    private function uprightReach(dc as Dc, index as Number, numeralFont as FontType, ink as Number, radians as Decimal) as Float {
        var halfWidth = dc.getTextWidthInPixels(texts[index], numeralFont) / 2.0;

        return ((halfWidth * Math.cos(radians).abs()) + ((ink / 2.0) * Math.sin(radians).abs())).toFloat();
    }

    //! Half the descent below the digits, less half the air above them
    private function shiftOf(dc as Dc, numeralFont as FontType, ink as Number) as Float {
        var ascent = Fonts.ascentOf(dc, numeralFont);
        var descent = dc.getFontHeight(numeralFont) - ascent;
        var air = ascent - ink;

        return (descent - air) / 2.0;
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

    //! Vector fonts if the watch can turn text, the system fonts otherwise
    private function chooseFont(dc as Dc) as Void {
        font = SYSTEM_FONT;
        highlightFont = HIGHLIGHT_SYSTEM_FONT;
        isTurned = false;

        if (!(Graphics has :getVectorFont) || !(dc has :drawAngledText)) {
            return;
        }

        var vectorFont = vectorFontFor(dc, SYSTEM_FONT);
        var highlightVectorFont = vectorFontFor(dc, HIGHLIGHT_SYSTEM_FONT);

        if ((vectorFont != null) && (highlightVectorFont != null)) {
            font = vectorFont;
            highlightFont = highlightVectorFont;
            isTurned = true;
        }
    }

    //! A touch smaller than the system font it is sized off
    private function vectorFontFor(dc as Dc, systemFont as FontType) as VectorFont? {
        return Graphics.getVectorFont({
            :face => FACES,
            :size => dc.getFontHeight(systemFont) * SIZE_NUMERATOR / SIZE_DIVISOR
        });
    }
}

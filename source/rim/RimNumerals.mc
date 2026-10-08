import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! 01 through 24 against the edge of the glass, 24 at the bottom. Turned to
//! face the middle, the bottom half flipped so it does not read upside down;
//! a watch without vector fonts gets them upright. Gray; one can be picked
//! out over the drawn face, a font step larger in its own color, centered on
//! the others' line, within a box worked out once.
class RimNumerals {

    private const COUNT = Dial.HOURS;
    private const FORMAT = "%02d";

    //! The system fonts the vector ones are sized off, and fall back to
    private const SYSTEM_FONT = Graphics.FONT_XTINY;
    private const HIGHLIGHT_SYSTEM_FONT = Graphics.FONT_TINY;

    //! The vector font a touch smaller than the system one
    private const SIZE_NUMERATOR = 4;
    private const SIZE_DIVISOR = 5;

    //! In order: the first the watch carries is used
    private const FACES = ["RobotoCondensedBold", "RobotoCondensedRegular", "RobotoRegular", "Swiss721Regular"];

    private const JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private const COLOR = Palette.GRAY;

    //! Past the box on every side, for the smoothed edges
    private const PADDING = 1;

    private var font as FontType = SYSTEM_FONT;
    private var highlightFont as FontType = HIGHLIGHT_SYSTEM_FONT;
    private var isTurned as Boolean = false;

    //! What a highlight paints its gray numeral over with
    private var background as Number = Graphics.COLOR_BLACK;

    //! Resolved in prepare(): how far the digits may reach, how tall they
    //! are, and how far the font box center sits below the digits' center
    private var outerEdge as Number = 0;
    private var inkHeight as Number = 0;
    private var descentShift as Float = 0.0;
    private var highlightInk as Number = 0;
    private var highlightShift as Float = 0.0;

    //! The nearest the digits come to the middle, from the center
    private var innerEdge as Number = 0;

    //! Per numeral, resolved in prepare(), plain and highlighted; a box is
    //! left, top, right and bottom, cut down to the screen
    private var texts as Array<String>;
    private var angles as Array<Number>;
    private var xs as Array<Number>;
    private var ys as Array<Number>;
    private var highlightXs as Array<Number>;
    private var highlightYs as Array<Number>;
    private var boxes as Array<Array<Number> >;

    function initialize() {
        texts = new [COUNT] as Array<String>;
        angles = new [COUNT] as Array<Number>;
        xs = new [COUNT] as Array<Number>;
        ys = new [COUNT] as Array<Number>;
        highlightXs = new [COUNT] as Array<Number>;
        highlightYs = new [COUNT] as Array<Number>;
        boxes = new [COUNT] as Array<Array<Number> >;

        for (var index = 0; index < COUNT; index++) {
            // Midnight reads as 24, not 0.
            var hour = (index == 0) ? COUNT : index;

            texts[index] = hour.format(FORMAT);
        }
    }

    function setBackground(background as Number) as Void {
        self.background = background;
    }

    //! After Dial.setup()
    function prepare(dc as Dc) as Void {
        chooseFont(dc);

        outerEdge = Dial.rim - Dial.air;
        inkHeight = Fonts.digitHeightOf(font);
        descentShift = shiftOf(dc, font, inkHeight);
        highlightInk = Fonts.digitHeightOf(highlightFont);
        highlightShift = shiftOf(dc, highlightFont, highlightInk);
        innerEdge = outerEdge - inkHeight;

        for (var index = 0; index < COUNT; index++) {
            if (isTurned) {
                placeTurned(index);
            } else {
                placeUpright(dc, index);
            }

            boxes[index] = boxAround(dc, index);
        }
    }

    function inner() as Number {
        return innerEdge;
    }

    //! All of them gray
    function draw(dc as Dc) as Void {
        for (var index = 0; index < COUNT; index++) {
            drawText(dc, index, font, xs[index], ys[index], COLOR);
        }
    }

    //! Over a face with the numeral drawn gray: the gray one painted over in
    //! the background, which covers it exactly, then the larger one
    function drawHighlight(dc as Dc, index as Number, color as Number) as Void {
        drawText(dc, index, font, xs[index], ys[index], background);
        drawText(dc, index, highlightFont, highlightXs[index], highlightYs[index], color);
    }

    //! Left, top, right and bottom of where drawHighlight() reaches
    function boxOf(index as Number) as Array<Number> {
        return boxes[index];
    }

    private function drawText(dc as Dc, index as Number, numeralFont as FontType, x as Number, y as Number, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (isTurned) {
            dc.drawAngledText(x, y, numeralFont as VectorFont, texts[index], JUSTIFY, angles[index]);
        } else {
            dc.drawText(x, y, numeralFont, texts[index], JUSTIFY);
        }
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

    //! The highlight's font box about its center, which takes in the gray
    //! numeral under it. Turned, it may lie at any angle, so the box takes in
    //! the circle around it.
    private function boxAround(dc as Dc, index as Number) as Array<Number> {
        var width = dc.getTextWidthInPixels(texts[index], highlightFont);
        var height = dc.getFontHeight(highlightFont);
        var halfWidth = (width / 2) + PADDING;
        var halfHeight = (height / 2) + PADDING;
        var x = highlightXs[index];
        var y = highlightYs[index];

        if (isTurned) {
            var half = Math.ceil(Math.sqrt((width * width) + (height * height)) / 2).toNumber() + PADDING;

            halfWidth = half;
            halfHeight = half;
        }

        return [
            Numbers.max(Numbers.min(x, xs[index]) - halfWidth, 0),
            Numbers.max(Numbers.min(y, ys[index]) - halfHeight, 0),
            Numbers.min(Numbers.max(x, xs[index]) + halfWidth + 1, Dial.screenWidth),
            Numbers.min(Numbers.max(y, ys[index]) + halfHeight + 1, Dial.screenHeight)
        ];
    }

    //! Half the descent below the digits, less half the air above them
    private function shiftOf(dc as Dc, numeralFont as FontType, ink as Number) as Float {
        var ascent = Fonts.ascentOf(numeralFont);
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

    //! Vector fonts if the watch carries one of the faces, the system fonts
    //! upright otherwise
    private function chooseFont(dc as Dc) as Void {
        font = SYSTEM_FONT;
        highlightFont = HIGHLIGHT_SYSTEM_FONT;
        isTurned = false;

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

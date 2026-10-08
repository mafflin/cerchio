import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! A circle just inside the numerals, or against the glass without them, in
//! the day's colors, a gap wherever the color changes; whole in the fallback
//! color until the sun is known. Solar
//! noon is a piece of the line as long as the line is wide, split off by a
//! gap either side. drawArc works in whole degrees, too coarse for a gap, so
//! the sectors run edge to edge and the gaps are cut across them as lines.
class DayCircle {

    //! The line's width: a base, plus a share of the radius so the denser
    //! AMOLED glass gets a heavier line
    private const PEN_BASE = 2;
    private const PEN_DIVISOR = 54;

    //! Air between the numerals and the circle, as a share of the radius
    private const GAP_DIVISOR = 32;

    //! A gap along the circle: a share of the radius past an offset, so it
    //! grows faster than the screen - the small MIP glass needs little, the
    //! dense AMOLED glass more
    private const SPLIT_OFFSET = 40;
    private const SPLIT_DIVISOR = 28;

    private var radius as Number = 0;
    private var penWidth as Number = 1;

    //! How far the pen reaches either side of the radius, rounded up
    private var penReach as Number = 1;

    //! Pixels: how wide a cut is, and how far it reaches either side of the
    //! radius to clear the line
    private var cutWidth as Number = 1;
    private var cutReach as Number = 1;

    private var background as Number = Graphics.COLOR_BLACK;

    private var dayColors as DayColors;

    function initialize(dayColors as DayColors) {
        self.dayColors = dayColors;
    }

    function setBackground(background as Number) as Void {
        self.background = background;
    }

    //! The pen reaches half its width past the radius. Null for no numerals:
    //! the line's outer edge is the glass.
    function prepare(numeralsInnerEdge as Number?) as Void {
        penWidth = PEN_BASE + (Dial.rim / PEN_DIVISOR);
        penReach = (penWidth + 1) / 2;
        radius = (numeralsInnerEdge == null) ? (Dial.rim - penReach) : (numeralsInnerEdge - (Dial.rim / GAP_DIVISOR) - penReach);

        cutWidth = (Dial.rim - SPLIT_OFFSET) / SPLIT_DIVISOR;
        cutReach = (penWidth / 2) + 1;
    }

    //! The line's middle, from the center
    function middle() as Number {
        return radius;
    }

    //! The line's inner edge, from the center
    function inner() as Number {
        return radius - penReach;
    }

    function width() as Number {
        return penWidth;
    }

    function draw(dc as Dc) as Void {
        var sunrise = dayColors.sunrise();
        var sunset = dayColors.sunset();
        var zenith = dayColors.zenith();

        dc.setPenWidth(penWidth);

        if ((sunrise == null) || (sunset == null) || (zenith == null)) {
            dc.setColor(dayColors.colorAt(0), Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(Dial.centerX, Dial.centerY, radius);
            return;
        }

        drawSectors(dc, sunrise, sunset);

        dc.setPenWidth(cutWidth);
        dc.setColor(background, Graphics.COLOR_TRANSPARENT);

        drawCuts(dc, sunrise, sunset);
        drawGapsAround(dc, zenith, cutWidth);
    }

    //! Cuts either side of a piece of the line as long as the line is wide
    function drawGapsAround(dc as Dc, position as Float, gapLength as Number) as Void {
        var offset = degreesAlong((penWidth + gapLength) / 2.0);

        dc.setPenWidth(gapLength);
        dc.setColor(background, Graphics.COLOR_TRANSPARENT);

        drawCut(dc, position - offset);
        drawCut(dc, position + offset);
    }

    //! Sunrise round to sunrise, through dusk and dawn when they are known
    private function drawSectors(dc as Dc, sunrise as Float, sunset as Float) as Void {
        var dawn = dayColors.dawn();
        var dusk = dayColors.dusk();

        drawSector(dc, sunrise, sunset);

        if ((dawn == null) || (dusk == null)) {
            drawSector(dc, sunset, sunrise);
            return;
        }

        drawSector(dc, sunset, dusk);
        drawSector(dc, dusk, dawn);
        drawSector(dc, dawn, sunrise);
    }

    //! At every color change
    private function drawCuts(dc as Dc, sunrise as Float, sunset as Float) as Void {
        var dawn = dayColors.dawn();
        var dusk = dayColors.dusk();

        drawCut(dc, sunrise);
        drawCut(dc, sunset);

        if ((dawn != null) && (dusk != null)) {
            drawCut(dc, dawn);
            drawCut(dc, dusk);
        }
    }

    //! Clockwise between two color changes, in the color at the first. Both
    //! ends rounded, so neighbors meet on the same whole degree.
    private function drawSector(dc as Dc, from as Float, to as Float) as Void {
        dc.setColor(dayColors.colorAt(from), Graphics.COLOR_TRANSPARENT);
        dc.drawArc(Dial.centerX, Dial.centerY, radius, Graphics.ARC_CLOCKWISE, screenDegrees(from), screenDegrees(to));
    }

    //! Across the line at a dial position, in the background color
    private function drawCut(dc as Dc, position as Float) as Void {
        var radians = Dial.radiansOf(position);
        var inner = radius - cutReach;
        var outer = radius + cutReach;

        dc.drawLine(Dial.pointX(radians, inner), Dial.pointY(radians, inner), Dial.pointX(radians, outer), Dial.pointY(radians, outer));
    }

    //! drawArc's whole degrees, counterclockwise from three o'clock
    private function screenDegrees(position as Float) as Number {
        return Dial.pixel(Dial.TOP_DEGREES - position);
    }

    //! The degrees a length along the circle spans
    private function degreesAlong(pixels as Float or Number) as Float {
        return Math.toDegrees(pixels.toFloat() / radius).toFloat();
    }
}

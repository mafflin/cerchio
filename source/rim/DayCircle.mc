import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! A circle against the glass in the day's colors, a gap wherever the color
//! changes; whole in the fallback color until the sun is known. drawArc
//! works in whole degrees, too coarse for a gap, so the sectors run edge to
//! edge and the gaps are cut across them as lines.
class DayCircle {

    //! The line's width: a base, plus a share of the radius so the denser
    //! AMOLED glass gets a heavier line
    private const PEN_BASE = 2;
    private const PEN_DIVISOR = 54;

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

    private var daylight as Daylight;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
    }

    //! The pen reaches half its width past the radius: the line's outer edge
    //! is the glass.
    function prepare() as Void {
        penWidth = PEN_BASE + (Dial.rim / PEN_DIVISOR);
        penReach = (penWidth + 1) / 2;
        radius = Dial.rim - penReach;

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
        var sunrise = daylight.sunrise();
        var sunset = daylight.sunset();

        dc.setPenWidth(penWidth);

        if ((sunrise == null) || (sunset == null)) {
            dc.setColor(DayColors.FALLBACK, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(Dial.centerX, Dial.centerY, radius);
            return;
        }

        drawSectors(dc, sunrise, sunset);

        dc.setPenWidth(cutWidth);
        dc.setColor(Palette.BACKGROUND, Graphics.COLOR_TRANSPARENT);

        drawCuts(dc, sunrise, sunset);
    }

    //! Cuts either side of a piece of the line of the given length, as wide
    //! as the cuts at the color changes
    function drawGapsAround(dc as Dc, position as Float, length as Number) as Void {
        var offset = degreesAlong((length + cutWidth) / 2.0);

        dc.setPenWidth(cutWidth);
        dc.setColor(Palette.BACKGROUND, Graphics.COLOR_TRANSPARENT);

        drawCut(dc, position - offset);
        drawCut(dc, position + offset);
    }

    //! Sunrise round to sunrise, through dusk and dawn when they are known;
    //! minutes past midnight
    private function drawSectors(dc as Dc, sunrise as Number, sunset as Number) as Void {
        var dawn = daylight.dawn();
        var dusk = daylight.dusk();

        drawSector(dc, sunrise, sunset, DayColors.DAY);

        if ((dawn == null) || (dusk == null)) {
            drawSector(dc, sunset, sunrise, DayColors.NIGHT);
            return;
        }

        drawSector(dc, sunset, dusk, DayColors.TWILIGHT);
        drawSector(dc, dusk, dawn, DayColors.NIGHT);
        drawSector(dc, dawn, sunrise, DayColors.TWILIGHT);
    }

    //! At every color change; minutes past midnight
    private function drawCuts(dc as Dc, sunrise as Number, sunset as Number) as Void {
        var dawn = daylight.dawn();
        var dusk = daylight.dusk();

        drawCut(dc, Dial.positionOfMinute(sunrise));
        drawCut(dc, Dial.positionOfMinute(sunset));

        // Met at midnight, in a white night: no night between them, and no
        // change of color.
        if ((dawn != null) && (dusk != null) && (dawn != dusk)) {
            drawCut(dc, Dial.positionOfMinute(dawn));
            drawCut(dc, Dial.positionOfMinute(dusk));
        }
    }

    //! Clockwise between two color changes, minutes past midnight, in the
    //! given color. Both ends rounded, so neighbors meet on the same whole
    //! degree. Ends on the same degree are not left to drawArc: a sliver is
    //! left out, and all but a sliver of the circle is drawn whole.
    private function drawSector(dc as Dc, fromMinute as Number, toMinute as Number, color as Number) as Void {
        var from = Dial.positionOfMinute(fromMinute);
        var to = Dial.positionOfMinute(toMinute);
        var start = screenDegrees(from);
        var end = screenDegrees(to);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        if (start != end) {
            dc.drawArc(Dial.centerX, Dial.centerY, radius, Graphics.ARC_CLOCKWISE, start, end);
            return;
        }

        var span = to - from;

        if (span < 0) {
            span += Dial.DEGREES_PER_CIRCLE;
        }

        if (span > Dial.HALF_TURN) {
            dc.drawCircle(Dial.centerX, Dial.centerY, radius);
        }
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
        return Numbers.round(Dial.TOP_DEGREES - position);
    }

    //! The degrees a length along the circle spans
    private function degreesAlong(pixels as Float or Number) as Float {
        return Math.toDegrees(pixels.toFloat() / radius).toFloat();
    }
}

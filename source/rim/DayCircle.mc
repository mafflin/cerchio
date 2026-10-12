import Toybox.Graphics;
import Toybox.Lang;

//! The day's colors around the glass. drawArc's whole degrees are too
//! coarse for gaps, so gaps are cut across as lines.
class DayCircle {

    //! Grows with the radius: heavier on dense AMOLED
    private const PEN_BASE = 2;
    private const PEN_DIVISOR = 54;

    //! Gap width; grows faster than the screen
    private const SPLIT_OFFSET = 40;
    private const SPLIT_DIVISOR = 28;

    private var radius as Number = 0;
    private var penWidth as Number = 1;

    private var penReach as Number = 1;

    private var cutWidth as Number = 1;
    private var cutReach as Number = 1;

    private var daylight as Daylight;

    function initialize(daylight as Daylight) {
        self.daylight = daylight;
    }

    //! Outer edge on the glass
    function prepare() as Void {
        penWidth = PEN_BASE + (Dial.rim / PEN_DIVISOR);
        penReach = (penWidth + 1) / 2;
        radius = Dial.rim - penReach;

        cutWidth = (Dial.rim - SPLIT_OFFSET) / SPLIT_DIVISOR;
        cutReach = (penWidth / 2) + 1;
    }

    function middle() as Number {
        return radius;
    }

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

    private function drawCuts(dc as Dc, sunrise as Number, sunset as Number) as Void {
        var dawn = daylight.dawn();
        var dusk = daylight.dusk();

        drawCut(dc, Dial.positionOfMinute(sunrise));
        drawCut(dc, Dial.positionOfMinute(sunset));

        // Equal in a white night: no color change
        if ((dawn != null) && (dusk != null) && (dawn != dusk)) {
            drawCut(dc, Dial.positionOfMinute(dawn));
            drawCut(dc, Dial.positionOfMinute(dusk));
        }
    }

    //! Ends on one degree: drawArc can't, so a sliver is skipped and a near
    //! full circle drawn whole
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

    private function drawCut(dc as Dc, position as Float) as Void {
        var radians = Dial.radiansOf(position);
        var inner = radius - cutReach;
        var outer = radius + cutReach;

        dc.drawLine(Dial.pointX(radians, inner), Dial.pointY(radians, inner), Dial.pointX(radians, outer), Dial.pointY(radians, outer));
    }

    //! drawArc's degrees: counterclockwise from three o'clock
    private function screenDegrees(position as Float) as Number {
        return Numbers.round(Dial.TOP_DEGREES - position);
    }
}

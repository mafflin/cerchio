import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! A circle just inside the numerals, amber from sunrise to sunset and sky
//! blue from sunset to sunrise; whole in the fallback color until the sun
//! is known. Solar noon is a piece of the line as long as the line is wide,
//! split off by a gap either side.
class DayCircle {

    //! The line's width: a base, plus a share of the radius so the denser
    //! AMOLED glass gets a heavier line
    private const PEN_BASE = 3;
    private const PEN_DIVISOR = 54;

    //! Air between the numerals and the circle, as a share of the radius
    private const GAP_DIVISOR = 32;

    //! Either side of solar noon, along the circle: a share of the radius past
    //! an offset, so it grows faster than the screen - the small MIP glass
    //! needs little, the dense AMOLED glass more
    private const SPLIT_OFFSET = 40;
    private const SPLIT_DIVISOR = 28;

    private var radius as Number = 0;
    private var penWidth as Number = 1;

    //! Either side of solar noon: where its piece ends, and where the day
    //! arc picks up again past the split
    private var zenithHalf as Float = 0.0;
    private var splitEnd as Float = 0.0;

    private var dayColors as DayColors;

    function initialize(dayColors as DayColors) {
        self.dayColors = dayColors;
    }

    //! The pen reaches half its width past the radius
    function prepare(numeralsInnerEdge as Number) as Void {
        penWidth = PEN_BASE + (Dial.rim / PEN_DIVISOR);
        radius = numeralsInnerEdge - (Dial.rim / GAP_DIVISOR) - ((penWidth + 1) / 2);
        zenithHalf = degreesAlong(penWidth / 2.0);
        splitEnd = zenithHalf + degreesAlong((Dial.rim - SPLIT_OFFSET) / SPLIT_DIVISOR);
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

        drawDay(dc, sunrise, sunset, zenith);

        dc.setColor(dayColors.colorAt(sunset), Graphics.COLOR_TRANSPARENT);
        drawArc(dc, sunset, sunrise);
    }

    private function drawDay(dc as Dc, sunrise as Float, sunset as Float, zenith as Float) as Void {
        dc.setColor(dayColors.colorAt(sunrise), Graphics.COLOR_TRANSPARENT);

        drawArc(dc, sunrise, zenith - splitEnd);
        drawArc(dc, zenith - zenithHalf, zenith + zenithHalf);
        drawArc(dc, zenith + splitEnd, sunset);
    }

    //! Clockwise between two dial positions, either may lie a turn off
    private function drawArc(dc as Dc, from as Float, to as Float) as Void {
        dc.drawArc(Dial.centerX, Dial.centerY, radius, Graphics.ARC_CLOCKWISE, Dial.TOP_DEGREES - from, Dial.TOP_DEGREES - to);
    }

    //! The degrees a length along the circle spans
    private function degreesAlong(pixels as Float or Number) as Float {
        return Math.toDegrees(pixels.toFloat() / radius).toFloat();
    }
}

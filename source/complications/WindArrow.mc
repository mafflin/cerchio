import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

//! The wind field's icon: an arrow pointing where the wind blows, off the
//! weather's bearing. Drawn as three corners rather than a turned bitmap:
//! the bilinear filter makes part-opaque pixels a MIP panel cannot
//! composite, so a turned bitmap's tail wobbles with the bearing. Takes no
//! room without a bearing.
class WindArrow extends Icon {

    //! Corners on the 24 unit grid the SVGs use, scaled to the square; the
    //! right wing mirrors the left. A convex triangle: a notched dart would
    //! need two polygons, and smoothing leaves a seam where they meet.
    private const GRID = 24.0;
    private const MIDDLE = GRID / 2;
    private const APEX_X = 12;
    private const APEX_Y = 2;
    private const WING_X = 4;
    private const WING_Y = 20;

    //! As big as the other field icons
    private var square as Number;

    //! Where the wind blows from, north up; null when unknown
    private var bearing as Number? = null;

    //! Corners about the square's middle, held until the bearing moves
    private var corners as Array< Array<Float> >? = null;
    private var cornersBearing as Number? = null;

    //! No bitmap of its own to measure: the build sizes the field icons,
    //! 18px or 24px, so it takes one of theirs
    function initialize() {
        Icon.initialize(null);
        square = (WatchUi.loadResource(Rez.Drawables.FieldBattery) as BitmapResource).getHeight();
    }

    //! From the weather the phone last sent
    function refresh() as Void {
        var conditions = CurrentWeather.conditions();

        bearing = (conditions != null) ? conditions.windBearing : null;
    }

    function width() as Number {
        return (bearing != null) ? square : 0;
    }

    function height() as Number {
        return square;
    }

    function draw(dc as Dc, x as Number, y as Number) as Void {
        var turned = currentCorners();

        if (turned == null) {
            return;
        }

        var middleX = x + (square / 2.0);
        var middleY = y + (square / 2.0);

        dc.setColor(tint(), Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [Dial.pixel(middleX + turned[0][0]), Dial.pixel(middleY + turned[0][1])],
            [Dial.pixel(middleX + turned[1][0]), Dial.pixel(middleY + turned[1][1])],
            [Dial.pixel(middleX + turned[2][0]), Dial.pixel(middleY + turned[2][1])]
        ]);
    }

    //! Worked out again only when the bearing moves; null without one
    private function currentCorners() as Array< Array<Float> >? {
        var current = bearing;

        if (current == null) {
            return null;
        }

        if ((corners == null) || (current != cornersBearing)) {
            corners = cornersFor(current);
            cornersBearing = current;
        }

        return corners;
    }

    //! Apex first, turned to point downwind
    private function cornersFor(from as Number) as Array< Array<Float> > {
        // Screen y grows downward, so a positive angle is clockwise, as a
        // compass counts. The bearing is where the wind comes from; the arrow
        // points where it goes.
        var angle = Math.toRadians(from + Dial.HALF_TURN).toFloat();

        return [
            corner(APEX_X, APEX_Y, angle),
            corner(WING_X, WING_Y, angle),
            corner(GRID - WING_X, WING_Y, angle)
        ];
    }

    //! A grid point as an offset from the square's middle, turned by angle
    private function corner(gridX as Numeric, gridY as Numeric, angle as Float) as Array<Float> {
        var scale = square / GRID;
        var dx = ((gridX - MIDDLE) * scale).toFloat();
        var dy = ((gridY - MIDDLE) * scale).toFloat();
        var sine = Math.sin(angle).toFloat();
        var cosine = Math.cos(angle).toFloat();

        return [
            (dx * cosine) - (dy * sine),
            (dx * sine) + (dy * cosine)
        ];
    }
}

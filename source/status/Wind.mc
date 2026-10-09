import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

//! The wind in the status row: a compass ring with a dot on it where the
//! wind goes, strength said with color - see WindReading. Drawn, not a
//! bitmap: only the dot moves with the bearing, and a circle looks the same
//! wherever it lands, so no bearing draws worse than another.
class Wind extends Icon {

    //! On the 24 unit grid the SVGs use, scaled to the row's square: the
    //! ring's radius and line, and the dot's radius, centered on the ring
    private const GRID = 24.0;
    private const RING_RADIUS = 8.5;
    private const RING_WIDTH = 2.2;
    private const DOT_RADIUS = 3.4;

    //! Its own: nothing else reads the wind's strength
    private var windReading as WindReading;

    //! The square the row gives this icon, and the sizes scaled to it
    private var square as Number = 0;
    private var ringRadius as Number = 0;
    private var ringWidth as Number = 1;
    private var dotRadius as Number = 0;

    //! The dot's center from the square's middle, held until the bearing
    //! moves
    private var dotOffset as Array<Number>? = null;
    private var dotBearing as Number? = null;

    function initialize() {
        Icon.initialize(null);
        windReading = new WindReading();
    }

    //! Read here, once a minute: the row asks every icon before it draws
    function isReporting(settings as System.DeviceSettings) as Boolean {
        windReading.refresh();

        return windReading.bearing() != null;
    }

    //! No bitmap to measure: the size is the build's, 24px or 36px
    function setSquare(size as Number) as Void {
        if (size == square) {
            return;
        }

        var scale = size / GRID;

        square = size;
        ringRadius = Dial.pixel(RING_RADIUS * scale);
        ringWidth = Numbers.max(Dial.pixel(RING_WIDTH * scale), 1);
        dotRadius = Dial.pixel(DOT_RADIUS * scale);
        dotOffset = null;
    }

    function width() as Number {
        return square;
    }

    function height() as Number {
        return square;
    }

    protected function tint() as Number {
        return windReading.colorFor(Icon.tint());
    }

    function draw(dc as Dc, x as Number, y as Number) as Void {
        if (square == 0) {
            return;
        }

        var offset = currentDotOffset();
        var middleX = x + (square / 2);
        var middleY = y + (square / 2);

        dc.setColor(tint(), Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(ringWidth);
        dc.drawCircle(middleX, middleY, ringRadius);
        dc.fillCircle(middleX + offset[0], middleY + offset[1], dotRadius);
    }

    //! Worked out again only when the bearing or the square moves
    private function currentDotOffset() as Array<Number> {
        var bearing = windReading.bearing();

        if ((dotOffset == null) || (bearing != dotBearing)) {
            dotOffset = dotOffsetFor(bearing);
            dotBearing = bearing;
        }

        return dotOffset as Array<Number>;
    }

    //! On the ring, downwind: the bearing is where the wind comes from
    private function dotOffsetFor(bearing as Number?) as Array<Number> {
        var radians = Math.toRadians(((bearing != null) ? bearing : 0) + Dial.HALF_TURN);

        // Clockwise from north; screen y grows downward.
        return [
            Dial.pixel(ringRadius * Math.sin(radians)),
            Dial.pixel(-ringRadius * Math.cos(radians))
        ];
    }
}

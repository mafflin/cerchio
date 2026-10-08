import Toybox.Graphics;
import Toybox.Lang;

//! The face but the seconds, drawn off screen once a minute: a full update
//! copies all of it, a partial update only the box round the seconds.
//! The system may take the bitmap back; it is then made anew and redrawn.
class FaceBuffer {

    private const NO_MINUTE = -1;

    private var screenWidth as Number = 0;
    private var screenHeight as Number = 0;
    private var reference as BufferedBitmapReference? = null;

    //! The minute it was last drawn for
    private var drawnMinute as Number = NO_MINUTE;

    function initialize() {
    }

    function prepare(dc as Dc) as Void {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        reference = null;
        invalidate();
    }

    //! Draw it again before it is next used
    function invalidate() as Void {
        drawnMinute = NO_MINUTE;
    }

    function isCurrent(minute as Number) as Boolean {
        return minute == drawnMinute;
    }

    function markDrawn(minute as Number) as Void {
        drawnMinute = minute;
    }

    //! Null when the graphics pool has no room for it
    function bitmap() as BufferedBitmap? {
        var current = reference;

        if (current != null) {
            var kept = current.get();

            if (kept != null) {
                return kept as BufferedBitmap;
            }
        }

        // Lost or never made: whatever it held is gone.
        invalidate();
        reference = Graphics.createBufferedBitmap({ :width => screenWidth, :height => screenHeight });

        return (reference as BufferedBitmapReference).get() as BufferedBitmap?;
    }
}

import Toybox.Graphics;
import Toybox.Lang;

//! Off screen face without the seconds. The system may reclaim the bitmap.
class FaceBuffer {

    private const NO_MINUTE = -1;

    private var reference as BufferedBitmapReference? = null;

    private var drawnMinute as Number = NO_MINUTE;

    //! Holds a face, however old
    private var hasFace as Boolean = false;

    function initialize() {
    }

    function prepare() as Void {
        reference = null;
        hasFace = false;
        invalidate();
    }

    function invalidate() as Void {
        drawnMinute = NO_MINUTE;
    }

    function isCurrent(minute as Number) as Boolean {
        return minute == drawnMinute;
    }

    function markDrawn(minute as Number) as Void {
        drawnMinute = minute;
        hasFace = true;
    }

    //! Never creates or draws: partial updates can't afford it
    function lastDrawn() as BufferedBitmap? {
        var current = reference;

        if ((current == null) || !hasFace) {
            return null;
        }

        return current.get() as BufferedBitmap?;
    }

    //! Null when the graphics pool is full
    function bitmap() as BufferedBitmap? {
        var current = reference;

        if (current != null) {
            var kept = current.get();

            if (kept != null) {
                return kept as BufferedBitmap;
            }
        }

        invalidate();
        hasFace = false;
        reference = Graphics.createBufferedBitmap({ :width => Dial.screenWidth, :height => Dial.screenHeight });

        return (reference as BufferedBitmapReference).get() as BufferedBitmap?;
    }
}

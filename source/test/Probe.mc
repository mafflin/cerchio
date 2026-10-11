import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

//! What the tests hand the code under test; left out of release builds
(:debug)
module Probe {

    //! A small round screen, for layout at the low end, whichever watch is
    //! simulated
    const SMALL_SCREEN = 218;

    //! A real complication, for a FieldKind's format(), which the kinds
    //! tested never read: the battery, which every watch carries
    function complication() as Complications.Complication {
        return Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
    }

    //! The small screen and the simulated watch's own, for layout run on both
    function screenSizes() as Array<Number> {
        return [SMALL_SCREEN, System.getDeviceSettings().screenWidth] as Array<Number>;
    }

    //! A square off screen bitmap, the dial set up on it. Keep it while
    //! drawing on its dc.
    function screen(size as Number) as Graphics.BufferedBitmap {
        var bitmap = Graphics.createBufferedBitmap({ :width => size, :height => size }).get() as Graphics.BufferedBitmap;

        Dial.setup(bitmap.getDc());

        return bitmap;
    }

    //! Where the view puts the data fields' row, from the top
    function fieldsTop() as Number {
        var height = Dial.screenHeight;

        return (height * 0.66).toNumber() + (height * 0.02).toNumber();
    }

    //! A day for the sun to be drawn by, at latitude degrees north
    function daylight(sunrise as Number?, sunset as Number?, latitude as Float?, declinationDegrees as Float) as Daylight {
        var daylight = new Daylight();

        daylight.setLatitudeSource(new LatitudeStub(latitude).method(:read));
        daylight.update(sunrise, sunset, 12 * 60, Math.toRadians(declinationDegrees));

        return daylight;
    }
}

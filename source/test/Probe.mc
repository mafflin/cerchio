import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

//! Test fixtures; not in release builds
(:debug)
module Probe {

    //! Low-end round screen
    const SMALL_SCREEN = 218;

    //! Battery: every watch has it. Unread by the kinds tested
    function complication() as Complications.Complication {
        return Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BATTERY));
    }

    function screenSizes() as Array<Number> {
        return [SMALL_SCREEN, System.getDeviceSettings().screenWidth] as Array<Number>;
    }

    //! Dial set up on it; keep it while drawing on its dc
    function screen(size as Number) as Graphics.BufferedBitmap {
        var bitmap = Graphics.createBufferedBitmap({ :width => size, :height => size }).get() as Graphics.BufferedBitmap;

        Dial.setup(bitmap.getDc());

        return bitmap;
    }

    //! As the view places it
    function fieldsTop() as Number {
        var height = Dial.screenHeight;

        return (height * 0.66).toNumber() + (height * 0.02).toNumber();
    }

    function daylight(sunrise as Number?, sunset as Number?, latitude as Float?, declinationDegrees as Float) as Daylight {
        var daylight = new Daylight();

        daylight.setLatitudeSource(new LatitudeStub(latitude).method(:read));
        daylight.update(sunrise, sunset, 12 * 60, Math.toRadians(declinationDegrees));

        return daylight;
    }
}

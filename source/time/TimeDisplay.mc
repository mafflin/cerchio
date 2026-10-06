import Toybox.Graphics;
import Toybox.Lang;

//! The time, centered, in the largest numeric system font.
class TimeDisplay {

    private const TIME_FORMAT = "$1$$2$";
    private const FIELD_FORMAT = "%02d";

    //! The largest numeric font, which Garmin sizes per device
    private const FONT = Graphics.FONT_NUMBER_THAI_HOT;

    private var color as Number = Graphics.COLOR_WHITE;
    private var centerX as Number = 0;
    private var centerY as Number = 0;

    function initialize() {
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function prepare(dc as Dc) as Void {
        centerX = dc.getWidth() / 2;
        centerY = dc.getHeight() / 2;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            centerY,
            FONT,
            currentTime(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function currentTime() as String {
        var clockTime = Clock.now();

        return Lang.format(TIME_FORMAT, [
            Clock.displayHour(clockTime.hour).format(FIELD_FORMAT),
            clockTime.min.format(FIELD_FORMAT)
        ]);
    }
}

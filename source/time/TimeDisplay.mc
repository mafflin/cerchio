import Toybox.Graphics;
import Toybox.Lang;

//! The time, centered, in the largest numeric system font, or one step
//! below it when the style asks.
class TimeDisplay {

    private const TIME_FORMAT = "$1$$2$";
    private const FIELD_FORMAT = "%02d";

    //! The largest numeric font and the one below it; Garmin sizes both
    //! per device
    private const FONT = Graphics.FONT_NUMBER_THAI_HOT;
    private const SMALL_FONT = Graphics.FONT_NUMBER_HOT;

    private var color as Number = Graphics.COLOR_WHITE;
    private var isSmall as Boolean = false;

    function initialize() {
    }

    function setColor(color as Number) as Void {
        self.color = color;
    }

    function setSmall(isSmall as Boolean) as Void {
        self.isSmall = isSmall;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Dial.centerX,
            Dial.centerY,
            isSmall ? SMALL_FONT : FONT,
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

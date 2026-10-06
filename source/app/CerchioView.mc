import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements.
class CerchioView extends WatchUi.WatchFace {

    private var background as Number = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;

    function initialize() {
        WatchFace.initialize();

        timeDisplay = new TimeDisplay();
    }

    function onLayout(dc as Dc) as Void {
        timeDisplay.prepare(dc);
    }

    function onUpdate(dc as Dc) as Void {
        Clock.read();
        paintBackground(dc);

        timeDisplay.draw(dc);
    }

    private function paintBackground(dc as Dc) as Void {
        dc.setColor(background, background);
        dc.clear();
    }
}

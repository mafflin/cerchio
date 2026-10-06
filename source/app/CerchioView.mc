import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements.
class CerchioView extends WatchUi.WatchFace {

    private var background as Number = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;
    private var numerals as RimNumerals;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    function initialize() {
        WatchFace.initialize();

        timeDisplay = new TimeDisplay();
        numerals = new RimNumerals();
    }

    //! Size everything for this screen
    function onLayout(dc as Dc) as Void {
        canSmooth = (dc has :setAntiAlias);

        Dial.setup(dc);
        numerals.prepare(dc);
    }

    function onUpdate(dc as Dc) as Void {
        Clock.read();
        smooth(dc);
        paintBackground(dc);

        numerals.draw(dc);
        timeDisplay.draw(dc);
    }

    //! Once per dc: the dc between two updates is the system's
    private function smooth(dc as Dc) as Void {
        if (canSmooth) {
            dc.setAntiAlias(true);
        }
    }

    private function paintBackground(dc as Dc) as Void {
        dc.setColor(background, background);
        dc.clear();
    }
}

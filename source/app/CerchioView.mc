import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements.
class CerchioView extends WatchUi.WatchFace {

    private var background as Number = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;
    private var daylight as Daylight;
    private var dayColors as DayColors;
    private var numerals as RimNumerals;
    private var dayCircle as DayCircle;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    function initialize() {
        WatchFace.initialize();

        timeDisplay = new TimeDisplay();
        daylight = new Daylight();
        dayColors = new DayColors(daylight);
        numerals = new RimNumerals();
        dayCircle = new DayCircle(dayColors);
    }

    //! Size everything for this screen
    function onLayout(dc as Dc) as Void {
        canSmooth = (dc has :setAntiAlias);

        Dial.setup(dc);
        numerals.prepare(dc);
        dayCircle.prepare(numerals.inner());
    }

    function onUpdate(dc as Dc) as Void {
        Clock.read();
        refreshReadings();
        smooth(dc);
        paintBackground(dc);

        numerals.draw(dc);
        dayCircle.draw(dc);
        timeDisplay.draw(dc);
    }

    //! Everything the draw reads, before anything draws
    private function refreshReadings() as Void {
        daylight.refresh();
        dayColors.refresh();
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

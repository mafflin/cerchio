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
    private var hourHand as HourHand;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    //! AMOLED: asleep, only the time shows
    private var needsBurnInProtection as Boolean = false;
    private var isAwake as Boolean = true;

    function initialize() {
        WatchFace.initialize();

        timeDisplay = new TimeDisplay();
        daylight = new Daylight();
        dayColors = new DayColors(daylight);
        numerals = new RimNumerals();
        dayCircle = new DayCircle(dayColors);
        dayCircle.setBackground(background);
        hourHand = new HourHand(dayCircle);
    }

    //! Size everything for this screen
    function onLayout(dc as Dc) as Void {
        canSmooth = (dc has :setAntiAlias);
        needsBurnInProtection = Clock.settings().requiresBurnInProtection;

        Dial.setup(dc);
        numerals.prepare(dc);
        dayCircle.prepare(numerals.inner());
        hourHand.prepare();
    }

    function onUpdate(dc as Dc) as Void {
        Clock.read();
        smooth(dc);
        paintBackground(dc);

        if (isAlwaysOn()) {
            timeDisplay.draw(dc);
            return;
        }

        refreshReadings();
        numerals.draw(dc);
        dayCircle.draw(dc);
        hourHand.draw(dc);
        timeDisplay.draw(dc);
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    private function isAlwaysOn() as Boolean {
        return needsBurnInProtection && !isAwake;
    }

    //! Everything the draw reads, before anything draws
    private function refreshReadings() as Void {
        if (daylight.refresh()) {
            dayColors.refresh();
        }
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

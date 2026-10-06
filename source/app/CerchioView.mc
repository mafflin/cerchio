import Toybox.Application.WatchFaceConfig;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements. Everything but the seconds hand is
//! drawn off screen once a minute; an update copies it and adds the hand.
class CerchioView extends WatchUi.WatchFace {

    //! Until the editor picks one
    private const DEFAULT_COLOR = Graphics.COLOR_WHITE;

    private const BACKGROUND = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;
    private var daylight as Daylight;
    private var dayColors as DayColors;
    private var numerals as RimNumerals;
    private var dayCircle as DayCircle;
    private var hourHand as HourHand;
    private var statusBar as StatusBar;
    private var secondsHand as SecondsHand;
    private var faceBuffer as FaceBuffer;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    //! AMOLED: asleep, only the time shows
    private var needsBurnInProtection as Boolean = false;
    private var isAwake as Boolean = true;

    //! Whether the system lets the hand move every second in low power mode
    private var partialUpdatesAllowed as Boolean;

    function initialize() {
        WatchFace.initialize();

        timeDisplay = new TimeDisplay();
        daylight = new Daylight();
        dayColors = new DayColors(daylight);
        numerals = new RimNumerals();
        dayCircle = new DayCircle(dayColors);
        dayCircle.setBackground(BACKGROUND);
        hourHand = new HourHand(dayCircle);
        statusBar = new StatusBar();
        secondsHand = new SecondsHand();
        faceBuffer = new FaceBuffer();

        partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
    }

    //! Size everything for this screen
    function onLayout(dc as Dc) as Void {
        canSmooth = (dc has :setAntiAlias);
        needsBurnInProtection = Clock.settings().requiresBurnInProtection;

        Dial.setup(dc);
        numerals.prepare(dc);
        dayCircle.prepare(numerals.inner());
        hourHand.prepare();
        secondsHand.prepare(dayCircle.width(), numerals.inner());
        faceBuffer.prepare(dc);
        loadSettings();
    }

    //! Accent: the seconds hand. Data: the rim numerals.
    function updateConfiguration(config as WatchFaceConfig.Settings) as Void {
        secondsHand.setColor(colorOf(config.accentColor));
        numerals.setColor(colorOf(config.complicationColor));

        faceBuffer.invalidate();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        // A partial update may have left a clip behind.
        dc.clearClip();
        Clock.read();

        if (isAlwaysOn()) {
            drawAlwaysOn(dc);
            return;
        }

        var face = currentFace();

        if (face != null) {
            dc.drawBitmap(0, 0, face);
        } else {
            drawFace(dc);
        }

        drawSecondsHand(dc, face != null);
    }

    //! Once a second in low power mode; has to stay within the power budget
    function onPartialUpdate(dc as Dc) as Void {
        if (isAlwaysOn() || !partialUpdatesAllowed) {
            return;
        }

        Clock.read();

        var face = currentFace();

        // Nothing to put back under the old hand.
        if (face == null) {
            return;
        }

        smooth(dc);
        secondsHand.drawPartial(dc, face);
    }

    //! The hand would freeze once the system stops calling onPartialUpdate,
    //! so it comes off the screen in low power mode instead
    function turnPartialUpdatesOff() as Void {
        partialUpdatesAllowed = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    //! Null without watch face configuration support: the defaults stand
    private function loadSettings() as Void {
        var settings = WatchFaceConfig.getSettings(null);

        if (settings != null) {
            updateConfiguration(settings);
        }
    }

    private function colorOf(chosen as WatchFaceConfig.Color?) as Number {
        if ((chosen != null) && (chosen.color != null)) {
            return chosen.color as Number;
        }

        return DEFAULT_COLOR;
    }

    private function isAlwaysOn() as Boolean {
        return needsBurnInProtection && !isAwake;
    }

    //! Only the time, straight on screen; the buffer is drawn again on waking
    private function drawAlwaysOn(dc as Dc) as Void {
        smooth(dc);
        paintBackground(dc);
        timeDisplay.draw(dc);

        faceBuffer.invalidate();
        secondsHand.forget();
    }

    //! The off screen face, drawn anew when the minute has moved on; null
    //! without room for it
    private function currentFace() as BufferedBitmap? {
        var face = faceBuffer.bitmap();

        if (face == null) {
            return null;
        }

        var minute = Clock.now().min;

        if (!faceBuffer.isCurrent(minute)) {
            drawFace(face.getDc());
            faceBuffer.markDrawn(minute);
        }

        return face;
    }

    //! Everything but the seconds hand
    private function drawFace(dc as Dc) as Void {
        smooth(dc);
        paintBackground(dc);
        refreshReadings();

        numerals.draw(dc);
        dayCircle.draw(dc);
        hourHand.draw(dc);
        statusBar.draw(dc);
        timeDisplay.draw(dc);
    }

    //! Asleep, the hand shows only if a partial update can move it, which
    //! takes the off screen face to copy back under it
    private function drawSecondsHand(dc as Dc, hasFace as Boolean) as Void {
        if (isAwake || (partialUpdatesAllowed && hasFace)) {
            smooth(dc);
            secondsHand.draw(dc);
        } else {
            // Nothing on screen to lift off next tick.
            secondsHand.forget();
        }
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
        dc.setColor(BACKGROUND, BACKGROUND);
        dc.clear();
    }
}

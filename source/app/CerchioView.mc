import Toybox.Application.WatchFaceConfig;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements. Everything but the seconds is drawn
//! off screen once a minute; an update copies it and adds the seconds dot.
class CerchioView extends WatchUi.WatchFace {

    //! Shares of the screen height: the line the status row mirrors, and the
    //! data fields' drop below it
    private const FRAME_RATIO = 0.66;
    private const FIELD_DROP_RATIO = 0.02;

    private const BACKGROUND = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;
    private var daylight as Daylight;
    private var dayColors as DayColors;
    private var numerals as RimNumerals;
    private var dayCircle as DayCircle;
    private var hourHand as HourHand;
    private var statusBar as StatusBar;
    private var fields as DataFields;
    private var secondsHand as SecondsHand;
    private var goalProgress as GoalProgress;
    private var goalDot as GoalDot;
    private var faceBuffer as FaceBuffer;
    private var editor as Editor;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    //! AMOLED: asleep, only the time shows
    private var needsBurnInProtection as Boolean = false;
    private var isAwake as Boolean = true;

    //! Whether the system lets the seconds move every second in low power
    //! mode
    private var partialUpdatesAllowed as Boolean;

    //! Whether the native watch face editor started the face
    private var editMode as Boolean;

    function initialize(editMode as Boolean) {
        WatchFace.initialize();

        self.editMode = editMode;

        timeDisplay = new TimeDisplay();
        daylight = Sun.daylight();
        dayColors = new DayColors(daylight);
        numerals = new RimNumerals();
        dayCircle = new DayCircle(dayColors);
        dayCircle.setBackground(BACKGROUND);
        hourHand = new HourHand(dayCircle);
        statusBar = new StatusBar();
        fields = new DataFields();
        secondsHand = new SecondsHand();
        goalProgress = new GoalProgress();
        goalDot = new GoalDot();
        faceBuffer = new FaceBuffer();
        editor = new Editor(fields);

        partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);
    }

    //! Size everything for this screen
    function onLayout(dc as Dc) as Void {
        canSmooth = (dc has :setAntiAlias);
        needsBurnInProtection = Clock.settings().requiresBurnInProtection;

        Dial.setup(dc);
        numerals.prepare(dc);
        placeCircle();
        faceBuffer.prepare(dc);
        placeFrame(dc);

        // The editor shows a snapshot; live updates are not worth the power.
        // Before the settings: a saved pick then swaps the subscription.
        if (!editMode) {
            subscribeToComplications();
        }

        loadSettings();
    }

    //! editedType is null while initializing
    function updateConfiguration(config as WatchFaceConfig.Settings, editedType as WatchFaceConfigType?) as Void {
        var shown = fields.shownIds();

        editor.apply(config, editedType);
        placeCircle();

        // Live updates follow the picks; none in the editor.
        if (!editMode) {
            fields.follow(shown);
        }

        applyColors();
        redraw();
    }

    //! The drawable the editor is about to pulse, null for none
    function getComplication(complication as ComplicationRef) as ComplicationDrawableRef? {
        var pulsed = editor.pulse(complication);

        if (pulsed != null) {
            redraw();
        }

        return pulsed;
    }

    //! The slot under a tap, or null
    function getTappedComplication(x as Number, y as Number) as Number? {
        return editor.tappedSlot(x, y);
    }

    function onComplicationChange(complicationId as Complications.Id) as Void {
        if (fields.refreshShowing(complicationId)) {
            redraw();
        }
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

        drawSeconds(dc, face != null);
    }

    //! Once a second in low power mode; has to stay within the power budget
    function onPartialUpdate(dc as Dc) as Void {
        if (isAlwaysOn() || !partialUpdatesAllowed) {
            return;
        }

        Clock.readTime();

        var face = currentFace();

        // Nothing to put back under the old seconds.
        if (face == null) {
            return;
        }

        smooth(dc);
        secondsHand.drawPartial(dc, face);
    }

    //! The seconds would freeze once the system stops calling onPartialUpdate,
    //! so they come off the screen in low power mode instead
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

    //! Inside the numerals, or against the glass for a style without them;
    //! the hour hand follows the circle. With the numerals, the seconds dot
    //! runs just outside the circle and the goal dot sits on the glass;
    //! without them, both keep inside the circle.
    private function placeCircle() as Void {
        var withNumerals = Styles.hasNumerals(editor.style());

        dayCircle.prepare(withNumerals ? numerals.inner() : null);
        hourHand.prepare();

        if (withNumerals) {
            secondsHand.placeOutside(dayCircle.outer());
        } else {
            secondsHand.placeInside(dayCircle.inner());
        }

        goalDot.prepare(dayCircle.width(), withNumerals ? null : dayCircle.inner());
    }

    //! The status row above the time mirrors the line the fields hang from
    private function placeFrame(dc as Dc) as Void {
        var frame = (Dial.screenHeight * FRAME_RATIO).toNumber();
        var top = frame + (Dial.screenHeight * FIELD_DROP_RATIO).toNumber();

        fields.prepare(dc, top);
        statusBar.mirror(frame);
    }

    //! Null without watch face configuration support: the defaults stand
    private function loadSettings() as Void {
        var settings = WatchFaceConfig.getSettings(null);

        if (settings != null) {
            updateConfiguration(settings, null);
        }
    }

    //! Accent: the seconds dot and the goal dot. Data: the time, the status
    //! row and the data fields.
    private function applyColors() as Void {
        var accent = editor.accentColor();
        var data = editor.dataColor();

        secondsHand.setColor(accent);
        goalDot.setColor(accent);
        timeDisplay.setColor(data);
        statusBar.setColor(data);
        fields.setColor(data);
    }

    //! Something on the off screen face has changed
    private function redraw() as Void {
        faceBuffer.invalidate();
        WatchUi.requestUpdate();
    }

    private function subscribeToComplications() as Void {
        fields.subscribe();
        Complications.registerComplicationChangeCallback(method(:onComplicationChange));
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

    //! Everything but the seconds
    private function drawFace(dc as Dc) as Void {
        smooth(dc);
        paintBackground(dc);
        refreshReadings();

        drawNumerals(dc);
        dayCircle.draw(dc);
        hourHand.draw(dc);
        goalDot.draw(dc);
        statusBar.draw(dc);
        fields.draw(dc, editor.pulsedSlot());
        timeDisplay.draw(dc);
    }

    //! Asleep, the hand shows only if a partial update can move it, which
    //! takes the off screen face to copy back under it.
    private function drawSeconds(dc as Dc, hasFace as Boolean) as Void {
        if (!isAwake && !(partialUpdatesAllowed && hasFace)) {
            // Nothing on screen to lift off next tick.
            secondsHand.forget();
            return;
        }

        smooth(dc);
        secondsHand.draw(dc);
    }

    //! Everything the draw reads, before anything draws
    private function refreshReadings() as Void {
        if (daylight.refresh()) {
            dayColors.refresh();
        }

        fields.refreshClocked();

        refreshGoal();
    }

    private function refreshGoal() as Void {
        goalProgress.refresh();
        goalDot.setShare(goalProgress.share());
    }

    private function drawNumerals(dc as Dc) as Void {
        if (Styles.hasNumerals(editor.style())) {
            numerals.draw(dc);
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

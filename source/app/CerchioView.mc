import Toybox.Application.WatchFaceConfig;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! The watch face: owns the elements. Everything but the seconds hand is
//! drawn off screen once a minute; an update copies it and adds the hand.
class CerchioView extends WatchUi.WatchFace {

    //! Shares of the screen height: the line the status row mirrors, and the
    //! data field's drop below it
    private const FRAME_RATIO = 0.66;
    private const FIELD_DROP_RATIO = 0.02;

    private const BACKGROUND = Graphics.COLOR_BLACK;

    private var timeDisplay as TimeDisplay;
    private var daylight as Daylight;
    private var dayColors as DayColors;
    private var numerals as RimNumerals;
    private var dayCircle as DayCircle;
    private var hourHand as HourHand;
    private var windReading as WindReading;
    private var statusBar as StatusBar;
    private var field as ComplicationField;
    private var secondsHand as SecondsHand;
    private var recoveryReading as RecoveryReading;
    private var activityReading as ActivityReading;
    private var goalProgress as GoalProgress;
    private var goalDot as GoalDot;
    private var faceBuffer as FaceBuffer;
    private var editor as Editor;

    //! Asked once, not every update
    private var canSmooth as Boolean = false;

    //! AMOLED: asleep, only the time shows
    private var needsBurnInProtection as Boolean = false;
    private var isAwake as Boolean = true;

    //! Whether the system lets the hand move every second in low power mode
    private var partialUpdatesAllowed as Boolean;

    //! Whether the native watch face editor started the face
    private var editMode as Boolean;

    function initialize(editMode as Boolean) {
        WatchFace.initialize();

        self.editMode = editMode;

        timeDisplay = new TimeDisplay();
        daylight = new Daylight();
        dayColors = new DayColors(daylight);
        numerals = new RimNumerals();
        dayCircle = new DayCircle(dayColors);
        dayCircle.setBackground(BACKGROUND);
        hourHand = new HourHand(dayCircle);
        windReading = new WindReading();
        statusBar = new StatusBar(windReading);
        field = new ComplicationField(SlotId.CENTER, Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY);
        secondsHand = new SecondsHand();
        recoveryReading = new RecoveryReading();
        activityReading = new ActivityReading();
        goalProgress = new GoalProgress();
        goalDot = new GoalDot();
        faceBuffer = new FaceBuffer();
        editor = new Editor(field, goalProgress);

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
        secondsHand.prepare();
        goalDot.prepare(dayCircle.width());
        faceBuffer.prepare(dc);
        placeFrame(dc);
        loadSettings();

        // The editor shows a snapshot; live updates are not worth the power.
        if (!editMode) {
            subscribeToComplications();
        }
    }

    //! editedType is null while initializing
    function updateConfiguration(config as WatchFaceConfig.Settings, editedType as WatchFaceConfigType?) as Void {
        editor.apply(config, editedType);
        applyColors();
        statusBar.showNotifications(editor.showsNotifications());
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
        if (!field.shows(complicationId)) {
            return;
        }

        field.refresh();
        redraw();
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

    //! The status row above the time mirrors the line the field hangs from
    private function placeFrame(dc as Dc) as Void {
        var frame = (Dial.screenHeight * FRAME_RATIO).toNumber();
        var top = frame + (Dial.screenHeight * FIELD_DROP_RATIO).toNumber();

        field.prepare(dc, Dial.centerX, top + (field.heightIn(dc) / 2));
        statusBar.mirror(frame);
    }

    //! Null without watch face configuration support: the defaults stand
    private function loadSettings() as Void {
        var settings = WatchFaceConfig.getSettings(null);

        if (settings != null) {
            updateConfiguration(settings, null);
        }
    }

    //! Accent: the seconds hand, the goal dot, and the recovery numeral within
    //! a day. Data: the time, the status row and the data field.
    private function applyColors() as Void {
        var accent = editor.accentColor();
        var data = editor.dataColor();

        secondsHand.setColor(accent);
        goalDot.setColor(accent);
        timeDisplay.setColor(data);
        statusBar.setColor(data);
        field.setColor(data);
    }

    //! Something on the off screen face has changed
    private function redraw() as Void {
        faceBuffer.invalidate();
        WatchUi.requestUpdate();
    }

    private function subscribeToComplications() as Void {
        Complications.subscribeToUpdates(field.getComplicationId());
        Complications.registerComplicationChangeCallback(method(:onComplicationChange));
    }

    private function drawField(dc as Dc) as Void {
        if (!editor.isPulsing()) {
            field.draw(dc);
        }
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
        drawGoalDot(dc);
        dayCircle.draw(dc);
        hourHand.draw(dc);
        statusBar.draw(dc);
        drawField(dc);
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

        windReading.refresh();
        recoveryReading.refresh();

        refreshGoal();
        refreshRecovery();
    }

    private function refreshGoal() as Void {
        var info = activityReading.refresh();

        if (info != null) {
            goalProgress.read(info);
        }

        goalDot.setShare(goalProgress.share());
    }

    private function drawGoalDot(dc as Dc) as Void {
        if (Styles.hasGoal(editor.style())) {
            goalDot.draw(dc);
        }
    }

    //! The recovery style picks out the numeral of the hours left in the
    //! accent color; past a day the 24, orange up to two days and red beyond,
    //! as the wind does. None once recovered.
    private function refreshRecovery() as Void {
        var hours = recoveryReading.hours();

        if (!Styles.hasRecovery(editor.style()) || (hours <= 0)) {
            numerals.setHighlightIndex(null);
            return;
        }

        numerals.setHighlightIndex(Numbers.min(hours, Dial.HOURS) % Dial.HOURS);
        numerals.setHighlightColor(recoveryColorOf(hours));
    }

    private function recoveryColorOf(hours as Number) as Number {
        if (hours <= Dial.HOURS) {
            return editor.accentColor();
        }

        return (hours <= (2 * Dial.HOURS)) ? Palette.ORANGE : Palette.RED;
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

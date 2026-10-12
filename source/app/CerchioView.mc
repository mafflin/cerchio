import Toybox.Application.WatchFaceConfig;
import Toybox.Complications;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! All but the seconds is drawn off screen once a minute.
class CerchioView extends WatchUi.WatchFace {

    //! Shares of the screen height
    private const FRAME_RATIO = 0.66;
    private const FIELD_DROP_RATIO = 0.02;

    private var timeDisplay as TimeDisplay;
    private var daylight as Daylight;
    private var dayCircle as DayCircle;
    private var rimMark as RimMark;
    private var statusBar as StatusBar;
    private var fields as DataFields;
    private var secondsHand as SecondsHand;
    private var goalDot as GoalDot;
    private var faceBuffer as FaceBuffer;
    private var editor as Editor;

    //! AMOLED: asleep, only the time shows
    private var needsBurnInProtection as Boolean = false;
    private var isAwake as Boolean = true;

    //! False once the power budget is exceeded
    private var partialUpdatesAllowed as Boolean = true;

    private var editMode as Boolean;

    //! A field changed; only the row is redrawn
    private var rowStale as Boolean = false;

    function initialize(editMode as Boolean) {
        WatchFace.initialize();

        self.editMode = editMode;

        timeDisplay = new TimeDisplay();
        daylight = Sun.daylight();
        dayCircle = new DayCircle(daylight);
        rimMark = new RimMark();
        statusBar = new StatusBar();
        fields = new DataFields();
        secondsHand = new SecondsHand();
        goalDot = new GoalDot();
        faceBuffer = new FaceBuffer();
        editor = new Editor(fields);
    }

    function onLayout(dc as Dc) as Void {
        needsBurnInProtection = Clock.settings().requiresBurnInProtection;

        Dial.setup(dc);

        dayCircle.prepare();
        rimMark.prepare(dayCircle.width(), dayCircle.middle());
        secondsHand.place(dayCircle.inner());
        goalDot.prepare(dayCircle.width(), dayCircle.inner());

        faceBuffer.prepare();
        placeFrame(dc);

        // Before loadSettings(), which may swap subscriptions. None in the editor.
        if (!editMode) {
            subscribeToComplications();
        }

        loadSettings();
    }

    //! editedType is null while initializing
    function updateConfiguration(config as WatchFaceConfig.Settings, editedType as WatchFaceConfigType?) as Void {
        var shown = fields.shownIds();

        editor.apply(config, editedType);

        if (!editMode) {
            fields.follow(shown);
        }

        applyColors();
        redraw();
    }

    function getComplication(complication as ComplicationRef) as ComplicationDrawableRef? {
        var pulsed = editor.pulse(complication);

        if (pulsed != null) {
            redraw();
        }

        return pulsed;
    }

    function getTappedComplication(x as Number, y as Number) as Number? {
        return fields.slotAt(x, y);
    }

    function onComplicationChange(complicationId as Complications.Id) as Void {
        if (fields.refreshShowing(complicationId)) {
            rowStale = true;
            WatchUi.requestUpdate();
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

    function onPartialUpdate(dc as Dc) as Void {
        if (isAlwaysOn() || !partialUpdatesAllowed) {
            return;
        }

        Clock.readTime();

        // Never redraw the whole face here: it would eat the power budget.
        var face = faceBuffer.lastDrawn();

        if (face == null) {
            return;
        }

        smooth(dc);

        if (rowStale) {
            copyRow(dc, face);
        }

        secondsHand.drawPartial(dc, face);
    }

    //! Hides the seconds asleep rather than freeze them
    function turnPartialUpdatesOff() as Void {
        partialUpdatesAllowed = false;
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        resume();
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        isAwake = true;
        resume();
    }

    //! Fields may have missed updates meanwhile
    private function resume() as Void {
        fields.refreshAll();
        redraw();
    }

    private function placeFrame(dc as Dc) as Void {
        var frame = (Dial.screenHeight * FRAME_RATIO).toNumber();
        var top = frame + (Dial.screenHeight * FIELD_DROP_RATIO).toNumber();

        fields.prepare(dc, top);
        statusBar.mirror(frame);
    }

    private function loadSettings() as Void {
        var settings = WatchFaceConfig.getSettings(null);

        if (settings != null) {
            updateConfiguration(settings, null);
        }
    }

    private function applyColors() as Void {
        var accent = editor.accentColor();
        var data = editor.dataColor();

        secondsHand.setColor(accent);
        goalDot.setColor(accent);
        timeDisplay.setColor(data);
        statusBar.setColor(data);
        fields.setColor(data);
    }

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

    private function drawAlwaysOn(dc as Dc) as Void {
        smooth(dc);
        paintBackground(dc);
        timeDisplay.draw(dc);

        faceBuffer.invalidate();
        secondsHand.forget();
    }

    //! Null without memory for it
    private function currentFace() as BufferedBitmap? {
        var face = faceBuffer.bitmap();

        if (face == null) {
            return null;
        }

        var minute = Clock.minuteOfDay();

        if (!faceBuffer.isCurrent(minute)) {
            drawFace(face.getDc());
            faceBuffer.markDrawn(minute);
        } else if (rowStale) {
            redrawRow(face);
        }

        return face;
    }

    //! The changed box, or null
    private function redrawRow(face as BufferedBitmap) as Array<Number>? {
        var faceDc = face.getDc();

        rowStale = false;
        smooth(faceDc);

        return fields.redraw(faceDc, editor.pulsedSlot());
    }

    private function copyRow(dc as Dc, face as BufferedBitmap) as Void {
        var box = redrawRow(face);

        if (box == null) {
            return;
        }

        dc.setClip(box[0], box[1], box[2] - box[0], box[3] - box[1]);
        dc.drawBitmap(0, 0, face);
        dc.clearClip();
    }

    private function drawFace(dc as Dc) as Void {
        rowStale = false;
        smooth(dc);
        paintBackground(dc);
        refreshReadings();

        dayCircle.draw(dc);
        drawMarks(dc);
        goalDot.draw(dc);
        statusBar.draw(dc);
        fields.draw(dc, editor.pulsedSlot());
        timeDisplay.draw(dc);
    }

    private function drawMarks(dc as Dc) as Void {
        var zenith = daylight.zenith();

        if (zenith != null) {
            rimMark.draw(dc, Dial.positionOfMinute(zenith), DayColors.DAY);
        }

        rimMark.draw(dc, Dial.positionOfMinute(Clock.minuteOfDay()), editor.accentColor());
    }

    //! Asleep, only if partial updates can move it
    private function drawSeconds(dc as Dc, hasFace as Boolean) as Void {
        if (!isAwake && !(partialUpdatesAllowed && hasFace)) {
            secondsHand.forget();
            return;
        }

        smooth(dc);
        secondsHand.draw(dc);
    }

    private function refreshReadings() as Void {
        daylight.refresh();

        fields.refreshClocked();

        goalDot.refresh();
    }

    //! Per update: the system may hand over a fresh dc
    private function smooth(dc as Dc) as Void {
        dc.setAntiAlias(true);
    }

    private function paintBackground(dc as Dc) as Void {
        dc.setColor(Palette.BACKGROUND, Palette.BACKGROUND);
        dc.clear();
    }
}

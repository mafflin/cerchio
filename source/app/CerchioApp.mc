import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! Round watch face: the time in the middle.
class CerchioApp extends Application.AppBase {

    //! Whether the native watch face editor started the face
    private var editMode as Boolean = false;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        if (state != null) {
            var launched = state[:launchedFromWatchFaceSettingsEditor];
            editMode = (launched instanceof Boolean) ? (launched as Boolean) : false;
        }
    }

    function onStop(state as Dictionary?) as Void {
    }

    //! The delegate carries editor edits and the power budget notice
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new CerchioView(editMode);

        return [ view, new CerchioDelegate(view) ];
    }
}

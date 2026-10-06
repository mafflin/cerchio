import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! Round watch face: the time in the middle.
class CerchioApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    //! The delegate carries the power budget notice
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new CerchioView();

        return [ view, new CerchioDelegate(view) ];
    }
}
